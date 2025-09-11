# res://Scripts/CharacterCreation/AbilityAssigning.gd
extends PanelContainer

# Order we present / persist abilities
const ABIL_ORDER := ["STR","DEX","CON","INT","WIS","CHA"]

# Assign these 6 paths in the inspector: StrBut, DexBut, ConBut, IntBut, WisBut, ChaBut
@export var button_paths: Array[NodePath] = []

# Resolved buttons live here
var _buttons: Array[Button] = []
var _labels: Array[Label] = []

# Current values (same order as ABIL_ORDER)
var ability_values: Array[int] = []

var _selected := -1

func _ready() -> void:
	# Resolve the paths safely
	_buttons.clear()
	_labels.clear()
	for p in button_paths:
		var b := get_node_or_null(p) as Button
		if b == null:
			push_error("AbilityAssigning: Button not found at path: %s" % [p])
		else:
			_buttons.append(b)
			var label: Label = null
			for child in b.get_children():
				if child is Label:
					label = child
					break
			if label == null:
				push_error("AbilityAssigning: Label not found under button %s" % b.name)
			_labels.append(label)

	# Guard: we need exactly 6 buttons
	if _buttons.size() != 6:
		push_error("AbilityAssigning: expected 6 buttons, got %d. Check 'button_paths' in the inspector." % _buttons.size())
		return

	# Connect pressed handlers
	for i in _buttons.size():
		var idx := i
		# Avoid duplicate connects in case of scene reloads
		if not _buttons[i].pressed.is_connected(_on_button_pressed.bind(idx)):
			_buttons[i].pressed.connect(_on_button_pressed.bind(idx))

	_clear_selection()

func init_assigning(_gen_method: int, _point_buy_pool: int, values: Array[int]) -> void:
	# Defensive copy and populate UI
	if values.size() != 6:
		push_error("init_assigning: expected 6 values, got %d" % values.size())
		return
	ability_values = values.duplicate()
	for i in _buttons.size():
		_set_button_text(i, ability_values[i])
		_set_highlight(i, false)
	_selected = -1

func _on_button_pressed(index: int) -> void:
	# First pick
	if _selected == -1:
		_selected = index
		_set_highlight(index, true)
		print("selected " + str(index))
		return

	# Same again → cancel
	if _selected == index:
		_set_highlight(index, false)
		_selected = -1
		return

	# Swap values
	var a := _selected
	var b := index
	assert(ability_values.size() > 0)
	var t := ability_values[a]
	ability_values[a] = ability_values[b]
	ability_values[b] = t

	_set_button_text(a, ability_values[a])
	_set_button_text(b, ability_values[b])

	_set_highlight(a, false)
	_selected = -1

func _set_button_text(i: int, value: int) -> void:
	# Update the button caption and its value label
	_buttons[i].text = "%s:" % ABIL_ORDER[i].capitalize()
	if i < _labels.size() and _labels[i] != null:
		_labels[i].text = str(value)

func _set_highlight(i: int, on: bool) -> void:
	if on:
		_buttons[i].add_theme_color_override("font_color", Color(1, 0.9, 0.2)) # soft yellow
		_buttons[i].add_theme_color_override("font_pressed_color", Color(1, 0.9, 0.2))
	else:
		_buttons[i].remove_theme_color_override("font_color")
		_buttons[i].remove_theme_color_override("font_pressed_color")

func _clear_selection() -> void:
	for i in _buttons.size():
		_set_highlight(i, false)
	_selected = -1

func get_final_values() -> Array[int]:
	return ability_values.duplicate()
