using Godot;

[GlobalClass]
public partial class FeatData : Resource
{
	[Export] public string Key { get; set; } = string.Empty;
	[Export] public string DisplayName { get; set; } = string.Empty;
	[Export(PropertyHint.MultilineText)] public string Description { get; set; } = string.Empty;
	[Export] public Godot.Collections.Array<string> Prerequisites { get; set; } = new Godot.Collections.Array<string>();
	[Export] public Godot.Collections.Array<string> Tags { get; set; } = new Godot.Collections.Array<string>();
}
