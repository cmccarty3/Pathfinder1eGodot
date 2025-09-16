using Godot;

[GlobalClass]
public partial class CharacterData : Resource
{
	[Export] public string Name { get; set; } = "New Hero";
	[Export] public int Level { get; set; } = 1;
	[Export] public ClassData ClassRef { get; set; }  // Reference to chosen class Resource
	[Export] public RaceData RaceRef { get; set; }    // Reference to chosen race Resource

	// New Background Fields
	[Export] public string Gender { get; set; }
	[Export] public string Alignment { get; set; }
	[Export] public string Deity { get; set; }
	[Export] public int Age { get; set; }
	[Export] public string Height { get; set; }
	[Export] public string Weight { get; set; }
	[Export] public string Homeland { get; set; }
	[Export] public Godot.Collections.Array<string> Traits { get; set; } = new Godot.Collections.Array<string>();
	
	// Base ability scores before modifiers (starts at 10s by default)
	[Export] public Godot.Collections.Dictionary<string, int> BaseAbilities { get; set; }
		= new Godot.Collections.Dictionary<string, int>() {
			{"STR", 10}, {"DEX", 10}, {"CON", 10},
			{"INT", 10}, {"WIS", 10}, {"CHA", 10}
		};

	// Compute some fundamental combat stats and saves based on current class and level
	public Godot.Collections.Dictionary GetBasics()
	{
		var basics = new Godot.Collections.Dictionary();
		if (ClassRef == null)
			return basics;  // No class assigned yet

		// Base Attack Bonus and Iterative Attacks
		basics["BAB"] = ClassRef.GetBAB(Level);
		basics["Attacks"] = ClassRef.GetIterativeAttacks(Level);

		// Saving throws
		var saves = new Godot.Collections.Dictionary();
		saves["Fort"] = ClassRef.GetSave("fort", Level);
		saves["Ref"]  = ClassRef.GetSave("reflex", Level);
		saves["Will"] = ClassRef.GetSave("will", Level);
		basics["Saves"] = saves;

		return basics;
	}
}
