# res://Scripts/CharacterCreation/AbilityAssigning.gd
extends PanelContainer

const ABIL_ORDER := ["STR","DEX","CON","INT","WIS","CHA"]

@onready var ability_buttons: Array[Button] = [
	$Margins/VBox/Grid/StrVal,
	$Margins/VBox/Grid/DexVal,
	$Margins/VBox/Grid/ConVal,
	$Margins/VBox/Grid/IntVal,
	$Margins/VBox/Grid/WisVal,
	$Margins/VBox/Grid/ChaVal,
]

var ability_values: Array[int] = []
var _selected_index := -1

func _ready() -> void:
	for i in ability_buttons.size():
		var idx := i
		ability_buttons[i].pressed.connect(func() -> void: _on_ability_pressed(idx))

func init_assigning(gen_method: int, point_buy_pool: int, values: Array[int]) -> void:
	ability_values = values.duplicate()
	for i in ability_buttons.size():
		ability_buttons[i].text = "%s: %d" % [ABIL_ORDER[i], ability_values[i]]
	_clear_selection()

func _on_ability_pressed(index: int) -> void:
	if _selected_index == -1:
		_selected_index = index
		_set_highlight(index, true)
		return

	if _selected_index == index:
		_set_highlight(index, false)
		_selected_index = -1
		return

	# swap
	var a := _selected_index
	var b := index
	var tmp := ability_values[a]
	ability_values[a] = ability_values[b]
	ability_values[b] = tmp
	ability_buttons[a].text = "%s: %d" % [ABIL_ORDER[a], ability_values[a]]
	ability_buttons[b].text = "%s: %d" % [ABIL_ORDER[b], ability_values[b]]

	_set_highlight(a, false)
	_selected_index = -1

func _set_highlight(i: int, on: bool) -> void:
	if on:
		ability_buttons[i].add_theme_color_override("font_color", Color(1, 0.9, 0.2)) # soft yellow
	else:
		ability_buttons[i].remove_theme_color_override("font_color")

func _clear_selection() -> void:
	for i in ability_buttons.size():
		_set_highlight(i, false)
	_selected_index = -1

func get_final_values() -> Array[int]:
	return ability_values.duplicate()
