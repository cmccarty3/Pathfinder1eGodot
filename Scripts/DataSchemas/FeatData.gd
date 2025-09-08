@icon("res://icon.svg")

extends Resource
class_name FeatData

@export var key: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""

# Keep prereqs simple for MVP (strings/keys). You can formalize later.
@export var prerequisites: PackedStringArray = []   # e.g., ["STR 13", "Power Attack"]
@export var tags: PackedStringArray = []            # ["Combat", "Teamwork"]
