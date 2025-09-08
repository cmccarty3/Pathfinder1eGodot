@icon("res://icon.svg")

extends Resource
class_name SpellData

enum School { ABJURATION, CONJURATION, DIVINATION, ENCHANTMENT, EVOCATION, ILLUSION, NECROMANCY, TRANSMUTATION, UNIVERSAL }

@export var key: StringName
@export var display_name: String = ""
@export var school: School = School.UNIVERSAL
@export var descriptors: PackedStringArray = []     # ["Fire", "Mind-Affecting"]

# Level by class, e.g., {"wizard":1, "cleric":1}
@export var level_by_class := {}

@export var casting_time: String = "Standard action"
@export var components: PackedStringArray = ["V","S"]
@export var range: String = "Close"
@export var duration: String = "Instantaneous"
@export var saving_throw: String = ""
@export var spell_resistance: String = ""
@export_multiline var rules_text: String = ""       # effect text
