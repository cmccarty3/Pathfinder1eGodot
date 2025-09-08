# res://Scripts/Main.gd
extends Control

# Point to the scene file (not the script) for Character Creation
const CC_SCENE_PATH := "res://Scenes/CharacterCreation/CharacterCreation.tscn"

@onready var _btn_new_game: Button = %NewGameButton

func _ready() -> void:
	if is_instance_valid(_btn_new_game):
		_btn_new_game.pressed.connect(_on_new_game_pressed)

func _on_new_game_pressed() -> void:
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.modulate.a = 0.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size = get_viewport_rect().size
	add_child(rect)

	var tw := create_tween()
	tw.tween_property(rect, "modulate:a", 1.0, 0.25)
	tw.finished.connect(func():
		get_tree().change_scene_to_file(CC_SCENE_PATH)
	)
