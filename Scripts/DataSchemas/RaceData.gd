@icon("res://icon.svg")

extends Resource
class_name RaceData

enum Size { FINE, DIMINUTIVE, TINY, SMALL, MEDIUM, LARGE, HUGE, GARGANTUAN, COLOSSAL }

@export var key: StringName
@export var display_name: String = ""
@export var size: Size = Size.MEDIUM
@export var base_speed: int = 30

# Ability modifiers as a dictionary for flexibility
@export var ability_mods := {"STR":0,"DEX":0,"CON":0,"INT":0,"WIS":0,"CHA":0}

@export var senses: PackedStringArray = []         # e.g., ["Darkvision 60 ft."]
@export var languages: PackedStringArray = []      # known/bonus languages if you like
@export var traits: PackedStringArray = []         # racial traits text keys
@export var skill_bonuses := {}                    # {"Perception": +2, "Stealth": +2}
