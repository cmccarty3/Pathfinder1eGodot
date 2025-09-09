using Godot;

[GlobalClass]  // Registers this class as a global type (like GDScript class_name)
public partial class RaceData : Resource
{
	// Enum for creature Size categories
	public enum Size { FINE, DIMINUTIVE, TINY, SMALL, MEDIUM, LARGE, HUGE, GARGANTUAN, COLOSSAL }

	[Export] public string Key { get; set; } = string.Empty;
	[Export] public string DisplayName { get; set; } = string.Empty;
	[Export] public Size RaceSize { get; set; } = Size.MEDIUM;
	[Export] public int BaseSpeed { get; set; } = 30;

	// Ability score modifiers (e.g. +2 STR for Orc, etc.)
	[Export] public Godot.Collections.Dictionary<string, int> AbilityMods { get; set; }
		= new Godot.Collections.Dictionary<string, int>() {
			{"STR", 0}, {"DEX", 0}, {"CON", 0},
			{"INT", 0}, {"WIS", 0}, {"CHA", 0}
		};

	// Racial senses (e.g. Darkvision) and languages and traits
	[Export] public Godot.Collections.Array<string> Senses { get; set; } = new Godot.Collections.Array<string>();
	[Export] public Godot.Collections.Array<string> Languages { get; set; } = new Godot.Collections.Array<string>();
	[Export] public Godot.Collections.Array<string> Traits { get; set; } = new Godot.Collections.Array<string>();

	// Racial skill bonuses (e.g. {"Perception": +2})
	[Export] public Godot.Collections.Dictionary<string, int> SkillBonuses { get; set; } 
		= new Godot.Collections.Dictionary<string, int>();
}
