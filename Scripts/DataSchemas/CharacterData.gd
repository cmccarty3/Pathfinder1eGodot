extends Resource
class_name CharacterData

@export var name: String = "New Hero"
@export var level: int = 1
@export var class_ref: ClassData
@export var race_ref: RaceData

func get_basics() -> Dictionary:
	if class_ref == null:
		return {}
	return {
		"BAB": class_ref.get_bab(level),
		"Attacks": class_ref.get_iterative_attacks(level),
		"Saves": {
			"Fort": class_ref.get_save(&"fort", level),
			"Ref":  class_ref.get_save(&"reflex", level),
			"Will": class_ref.get_save(&"will", level)
		}
	}
