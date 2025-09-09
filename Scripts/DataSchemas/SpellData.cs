using Godot;

[GlobalClass]
public partial class SpellData : Resource
{
	public enum School { ABJURATION, CONJURATION, DIVINATION, ENCHANTMENT, EVOCATION, ILLUSION, NECROMANCY, TRANSMUTATION, UNIVERSAL }

	[Export] public string Key { get; set; } = string.Empty;
	[Export] public string DisplayName { get; set; } = string.Empty;
	[Export] public School SchoolType { get; set; } = School.UNIVERSAL;
	[Export] public Godot.Collections.Array<string> Descriptors { get; set; } = new Godot.Collections.Array<string>();
	[Export] public Godot.Collections.Dictionary<string, int> LevelByClass { get; set; } = new Godot.Collections.Dictionary<string, int>();
	[Export] public string CastingTime { get; set; } = "Standard action";
	[Export] public Godot.Collections.Array<string> Components { get; set; } = new Godot.Collections.Array<string>() { "V", "S" };
	[Export] public string Range { get; set; } = "Close";
	[Export] public string Duration { get; set; } = "Instantaneous";
	[Export] public string SavingThrow { get; set; } = string.Empty;
	[Export] public string SpellResistance { get; set; } = string.Empty;
	[Export(PropertyHint.MultilineText)] public string RulesText { get; set; } = string.Empty;
}
