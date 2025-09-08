extends Control

# At top (near your other vars)
const ABIL_ORDER := ["Str", "Dex", "Con", "Int", "Wis", "Chr"]  # display text
# (If you prefer "Cha" instead of "Chr", just change it here.)

# Grab the six label nodes in order
@onready var _abil_labels: Array[Label] = [
	$AbilityGeneration/Margins/VBox/RollGrid/StrVal,
	$AbilityGeneration/Margins/VBox/RollGrid/DexVal,
	$AbilityGeneration/Margins/VBox/RollGrid/ConVal,
	$AbilityGeneration/Margins/VBox/RollGrid/IntVal,
	$AbilityGeneration/Margins/VBox/RollGrid/WisVal,
	$AbilityGeneration/Margins/VBox/RollGrid/ChaVal,
]

# ======= Ability Generation =======
enum GenMethod {
	POINT_BUY,
	ROLL_3D6,
	ROLL_3D6_REROLL1,
	ROLL_4D6_DROP_LOWEST,
	ROLL_4D6_REROLL1_DROP_LOWEST
}

@export var point_buy_pool: int = 15

var gen_method: int = GenMethod.POINT_BUY

# Rolls
var current_roll: Array[int] = []   # six numbers for the UI
var stored_roll: Array[int] = []    # snapshot when user clicks "Store"
var rolled_values: Array[int] = []  # what we pass to the next step (kept for compatibility)

# Panels
@onready var _panels := {
	"AbilityGeneration": $AbilityGeneration,
	"AbilityAssigning": $AbilityAssigning,
	"RaceChoose": $RaceChoose,
	"ClassChoose": $ClassChoose,
	"FinalizeCharacter": $FinalizeCharacter
}

# AbilityGeneration refs
@onready var _method_option: OptionButton = $AbilityGeneration/Margins/VBox/MethodOption
@onready var _method_desc: RichTextLabel = $AbilityGeneration/Margins/VBox/MethodDesc
@onready var _btn_back: Button = $AbilityGeneration/Margins/VBox/NavButtons/BackButton
@onready var _btn_next: Button = $AbilityGeneration/Margins/VBox/NavButtons/NextButton

# NEW: roll UI
@onready var _lbl_total: Label = $AbilityGeneration/Margins/VBox/RollRow/TotalLabel
@onready var _btn_store: Button = $AbilityGeneration/Margins/VBox/StoreRow/StoreButton
@onready var _btn_reroll: Button = $AbilityGeneration/Margins/VBox/StoreRow/RerollButton
@onready var _btn_revert: Button = $AbilityGeneration/Margins/VBox/StoreRow/RevertButton
@onready var _lbl_stored: Label = $AbilityGeneration/Margins/VBox/StoreRow/StoredLabel

# RNG
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_show_only("AbilityGeneration")
	_populate_generation_methods()
	_bind_generation_signals()
	_update_method_desc()
	_reset_roll_ui()

# ---------- populate/signals ----------

func _populate_generation_methods() -> void:
	_method_option.clear()
	_method_option.add_item("Point Buy", GenMethod.POINT_BUY)
	_method_option.add_item("3d6", GenMethod.ROLL_3D6)
	_method_option.add_item("3d6 (reroll 1s once)", GenMethod.ROLL_3D6_REROLL1)
	_method_option.add_item("4d6 (drop lowest)", GenMethod.ROLL_4D6_DROP_LOWEST)
	_method_option.add_item("4d6 (reroll 1s once, drop lowest)", GenMethod.ROLL_4D6_REROLL1_DROP_LOWEST)
	var idx := _method_option.get_item_index(GenMethod.POINT_BUY)
	if idx >= 0: _method_option.select(idx)

func _bind_generation_signals() -> void:
	_method_option.item_selected.connect(_on_generation_method_selected)
	_btn_next.pressed.connect(_on_generation_next_pressed)
	_btn_back.pressed.connect(_on_generation_back_pressed)
	_btn_back.disabled = true

	# NEW
	_btn_store.pressed.connect(_on_store_pressed)
	_btn_reroll.pressed.connect(_on_reroll_pressed)
	_btn_revert.pressed.connect(_on_revert_pressed)

func _on_generation_method_selected(index: int) -> void:
	gen_method = _method_option.get_item_id(index)
	_update_method_desc()
	# Clear current display if switching methods
	_reset_roll_ui()
	# Disable rolling on Point Buy; enable otherwise
	var rolling_allowed := gen_method != GenMethod.POINT_BUY
	_btn_reroll.disabled = not rolling_allowed

func _update_method_desc() -> void:
	var text := ""
	match gen_method:
		GenMethod.POINT_BUY:
			text = "[b]Point Buy[/b]\nDistribute a pool of points among your abilities. Pool: %d." % point_buy_pool
		GenMethod.ROLL_3D6:
			text = "[b]3d6[/b]\nRoll 3d6 per ability (range 3–18)."
		GenMethod.ROLL_3D6_REROLL1:
			text = "[b]3d6 (reroll 1s once)[/b]\nEach die that shows 1 is rerolled once."
		GenMethod.ROLL_4D6_DROP_LOWEST:
			text = "[b]4d6 (drop lowest)[/b]\nRoll 4d6, drop the lowest die; sum the highest three."
		GenMethod.ROLL_4D6_REROLL1_DROP_LOWEST:
			text = "[b]4d6 (reroll 1s once, drop lowest)[/b]\nReroll any 1s once, then drop the lowest."
	_method_desc.text = text

# ---------- roll actions ----------

func _on_reroll_pressed() -> void:
	if gen_method == GenMethod.POINT_BUY:
		return
	current_roll = _roll_by_method(gen_method)
	_update_roll_display()

func _on_store_pressed() -> void:
	if current_roll.size() != 6:
		return
	stored_roll = current_roll.duplicate()
	_lbl_stored.text = "Stored: %s (Total %d)" % [stored_roll, _sum(stored_roll)]
	_btn_revert.disabled = false

func _on_revert_pressed() -> void:
	if stored_roll.size() != 6:
		return
	current_roll = stored_roll.duplicate()
	_update_roll_display()

func _reset_roll_ui() -> void:
	current_roll.clear()
	_lbl_total.text = "Total: –"
	for i in _abil_labels.size():
		_abil_labels[i].text = "%s: -" % ABIL_ORDER[i]
	_lbl_stored.text = "Stored: –"
	_btn_revert.disabled = true
	var rolling_allowed := gen_method != GenMethod.POINT_BUY
	_btn_reroll.disabled = not rolling_allowed
	_btn_store.disabled = true


func _update_roll_display() -> void:
	for i in _abil_labels.size():
		var val_text := "-"
		if i < current_roll.size():
			val_text = str(current_roll[i])
		_abil_labels[i].text = "%s: %s" % [ABIL_ORDER[i], val_text]
	_lbl_total.text = "Total: %s" % (str(_sum(current_roll)) if current_roll.size() == 6 else "–")
	_btn_store.disabled = current_roll.size() != 6



# ---------- navigation ----------

func _on_generation_next_pressed() -> void:
	rolled_values.clear()
	if gen_method == GenMethod.POINT_BUY:
		# Point buy: nothing to pass; handled in next panel
		pass
	else:
		# Prefer the user-visible current roll if present; otherwise generate once
		rolled_values = current_roll.duplicate() if current_roll.size() == 6 else _roll_by_method(gen_method)

	_show_only("AbilityAssigning")
	# If your AbilityAssigning node has an initializer, call it here:
	# if _panels["AbilityAssigning"].has_method("init_assigning"):
	#     _panels["AbilityAssigning"].call("init_assigning", gen_method, point_buy_pool, rolled_values)

func _on_generation_back_pressed() -> void:
	pass # keep for future splash/menu

func _show_only(name: String) -> void:
	for k in _panels.keys():
		_panels[k].visible = (k == name)

# ---------- dice helpers ----------

func _roll_by_method(m: int) -> Array[int]:
	match m:
		GenMethod.ROLL_3D6:
			return _roll_array_3d6()
		GenMethod.ROLL_3D6_REROLL1:
			return _roll_array_3d6_reroll_ones()
		GenMethod.ROLL_4D6_DROP_LOWEST:
			return _roll_array_4d6_drop_lowest(false)
		GenMethod.ROLL_4D6_REROLL1_DROP_LOWEST:
			return _roll_array_4d6_drop_lowest(true)
	return []  # point buy

func _roll_die() -> int:
	return _rng.randi_range(1, 6)

func _roll_3d6_value(reroll_ones_once: bool) -> int:
	var total := 0
	for i in 3:
		var d := _roll_die()
		if reroll_ones_once and d == 1:
			d = _roll_die()
		total += d
	return total

func _roll_array_3d6() -> Array[int]:
	var arr: Array[int] = []
	for i in 6: arr.append(_roll_3d6_value(false))
	return arr

func _roll_array_3d6_reroll_ones() -> Array[int]:
	var arr: Array[int] = []
	for i in 6: arr.append(_roll_3d6_value(true))
	return arr

func _roll_4d6_drop_value(reroll_ones_once: bool) -> int:
	var dice: Array[int] = []
	for i in 4:
		var d := _roll_die()
		if reroll_ones_once and d == 1:
			d = _roll_die()
		dice.append(d)
	var sum := 0
	var min_val := 7
	for d in dice:
		sum += d
		if d < min_val: min_val = d
	return sum - min_val

func _roll_array_4d6_drop_lowest(reroll_ones_once: bool) -> Array[int]:
	var arr: Array[int] = []
	for i in 6: arr.append(_roll_4d6_drop_value(reroll_ones_once))
	return arr

func _sum(a: Array[int]) -> int:
	var t := 0
	for v in a: t += v
	return t
