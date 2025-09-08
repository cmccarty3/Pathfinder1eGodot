@icon("res://icon.svg") # swap for a nicer icon if you want
extends Resource
class_name ClassData

# --- enums / knobs ---
enum BABProg { FULL, THREE_QUARTERS, HALF }
enum SaveProg { GOOD, POOR }
enum SpellcastingKind { NONE, PREPARED, SPONTANEOUS }
enum CasterTradition { NONE, ARCANE, DIVINE, PSYCHIC, OTHER }

# --- basic info ---
@export var key: StringName         # "fighter", "wizard" (internal id)
@export var display_name: String = ""  # "Fighter", "Wizard"
@export var hit_die: int = 10
@export var skills_per_level: int = 2

# --- combat progressions ---
@export var bab_progression: BABProg = BABProg.FULL
@export var fort_save: SaveProg = SaveProg.GOOD
@export var reflex_save: SaveProg = SaveProg.POOR
@export var will_save: SaveProg = SaveProg.POOR

# --- proficiencies, skills, features ---
@export var class_skills: PackedStringArray = []
@export var weapon_proficiencies: PackedStringArray = []
@export var armor_proficiencies: PackedStringArray = []

# Index by *character level*. We’ll allocate 21 slots so you can use [1]..[20].
# Each entry is a list of feature names at that level.
@export var features_by_level: Array = []  # Array[PackedStringArray] is fine too

# --- spellcasting (optional) ---
@export var spellcasting: SpellcastingKind = SpellcastingKind.NONE
@export var caster_tradition: CasterTradition = CasterTradition.NONE
@export var caster_ability: StringName = &""   # "INT", "WIS", "CHA"

# For prepared/spontaneous casters:
# spells_per_day[level:int] = PackedInt32Array of slots for spell levels 0..9
# Example: {1: [3,1,0,0,0,0,0,0,0,0]}  (3 cantrips, 1 first-level)
@export var spells_per_day: Dictionary = {}
# For spontaneous (e.g., Sorcerer), optional:
# spells_known[level:int] = PackedInt32Array for 0..9
@export var spells_known: Dictionary = {}

func _init() -> void:
	if features_by_level.is_empty():
		features_by_level.resize(21) # use indices 1..20

# --- progression helpers ---
static func _good_save(level: int) -> int:
	# PF good save = 2 + floor(level/2)
	return 2 + int(floor(level / 2.0))

static func _poor_save(level: int) -> int:
	# PF poor save = floor(level/3)
	return int(floor(level / 3.0))

func get_save(which: StringName, level: int) -> int:
	var prog := SaveProg.POOR
	match which:
		&"fort":  prog = fort_save
		&"reflex": prog = reflex_save
		&"will":  prog = will_save
	return _good_save(level) if prog == SaveProg.GOOD else _poor_save(level)

func get_bab(level: int) -> int:
	match bab_progression:
		BABProg.FULL:            return level
		BABProg.THREE_QUARTERS:  return int(floor(level * 0.75))
		BABProg.HALF:            return int(floor(level * 0.5))
	return 0

func get_iterative_attacks(level: int) -> PackedInt32Array:
	var bab := get_bab(level)
	var hits: PackedInt32Array = []
	var cur := bab
	while cur > 0:
		hits.append(cur)
		cur -= 5 # iterative attacks at -5 steps (6/11/16 thresholds emerge naturally)
	return hits

func get_spells_per_day(level: int) -> PackedInt32Array:
	return spells_per_day.get(level, PackedInt32Array())

func get_spells_known(level: int) -> PackedInt32Array:
	return spells_known.get(level, PackedInt32Array())
