using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class ClassData : Resource
{
	// --- Enumerations for progression types ---
	public enum BABProg { FULL, THREE_QUARTERS, HALF }
	public enum SaveProg { GOOD, POOR }
	public enum SpellcastingKind { NONE, PREPARED, SPONTANEOUS }
	public enum CasterTradition { NONE, ARCANE, DIVINE, PSYCHIC, OTHER }

	// --- Basic class info ---
	[Export] public string Key { get; set; } = string.Empty;       // e.g. "fighter"
	[Export] public string DisplayName { get; set; } = string.Empty;  // e.g. "Fighter"
	[Export] public int HitDie { get; set; } = 10;                 // e.g. d10
	[Export] public int SkillsPerLevel { get; set; } = 2;

	// --- Combat progressions (BAB and saves) ---
	[Export] public BABProg BABProgression { get; set; } = BABProg.FULL;
	[Export] public SaveProg FortSave { get; set; } = SaveProg.GOOD;
	[Export] public SaveProg ReflexSave { get; set; } = SaveProg.POOR;
	[Export] public SaveProg WillSave { get; set; } = SaveProg.POOR;

	// --- Proficiencies and class skills ---
	[Export] public Godot.Collections.Array<string> ClassSkills { get; set; } = new Godot.Collections.Array<string>();
	[Export] public Godot.Collections.Array<string> WeaponProficiencies { get; set; } = new Godot.Collections.Array<string>();
	[Export] public Godot.Collections.Array<string> ArmorProficiencies { get; set; } = new Godot.Collections.Array<string>();

	// --- Class features by level ---
	// An array of length 21 (index 1..20 used) where each element is a list of feature names at that level.
	[Export] public Godot.Collections.Array GodotFeaturesByLevel { get; set; } = new Godot.Collections.Array();
	// (We use an untyped Array for inspector editing; each element should be a Godot.Collections.Array<string> of feature names.)

	// --- Spellcasting (if applicable) ---
	[Export] public SpellcastingKind Spellcasting { get; set; } = SpellcastingKind.NONE;
	[Export] public CasterTradition CasterType { get; set; } = CasterTradition.NONE;
	[Export] public string CasterAbility { get; set; } = string.Empty;  // e.g. "INT", "WIS", or "CHA"

	// Spells per day and spells known by level (for spellcasting classes).
	// Keyed by character level; values are arrays of 10 ints (slots for spell levels 0-9).
	[Export] public Godot.Collections.Dictionary<int, Godot.Collections.Array<int>> SpellsPerDay { get; set; }
		= new Godot.Collections.Dictionary<int, Godot.Collections.Array<int>>();
	[Export] public Godot.Collections.Dictionary<int, Godot.Collections.Array<int>> SpellsKnown { get; set; }
		= new Godot.Collections.Dictionary<int, Godot.Collections.Array<int>>();

	public ClassData()
	{
		// Initialize features-by-level array with 21 sub-arrays (index 0 unused, 1-20 correspond to levels).
		if (Engine.IsEditorHint())  // Only execute in editor (so that the resource shows 21 entries by default)
		{
			if (GodotFeaturesByLevel.Count == 0)
			{
				for (int lvl = 0; lvl <= 20; lvl++)
				{
					GodotFeaturesByLevel.Add(new Godot.Collections.Array<string>());
				}
			}
		}
	}

	// --- Helper methods for progression calculations ---
	private static int GoodSave(int level) 
	{
		// Pathfinder good save: 2 + floor(level/2)
		return 2 + (level / 2);
	}
	private static int PoorSave(int level) 
	{
		// Pathfinder poor save: floor(level/3)
		return level / 3;
	}

	public int GetSave(string which, int level)
	{
		// Determine which progression to use based on the provided save name.
		SaveProg prog;
		switch (which.ToLower())
		{
			case "fort":   prog = FortSave;   break;
			case "ref":    // allow shorthand "ref"
			case "reflex": prog = ReflexSave; break;
			case "will":   prog = WillSave;   break;
			default:       prog = SaveProg.POOR; break;
		}
		return (prog == SaveProg.GOOD) ? GoodSave(level) : PoorSave(level);
	}

	public int GetBAB(int level)
	{
		// Calculate Base Attack Bonus based on progression
		switch (BABProgression)
		{
			case BABProg.FULL:           return level;
			case BABProg.THREE_QUARTERS: return (level * 3) / 4;  // floor(level * 0.75)
			case BABProg.HALF:           return level / 2;        // floor(level * 0.5)
		}
		return 0;
	}

	public Godot.Collections.Array<int> GetIterativeAttacks(int level)
	{
		int bab = GetBAB(level);
		var attacks = new Godot.Collections.Array<int>();
		int current = bab;
		while (current > 0)
		{
			attacks.Add(current);
			current -= 5;
		}
		return attacks;
	}

	public Godot.Collections.Array<int> GetSpellsPerDay(int level)
	{
		return SpellsPerDay.ContainsKey(level) ? SpellsPerDay[level] : new Godot.Collections.Array<int>();
	}

	public Godot.Collections.Array<int> GetSpellsKnown(int level)
	{
		return SpellsKnown.ContainsKey(level) ? SpellsKnown[level] : new Godot.Collections.Array<int>();
	}
}
