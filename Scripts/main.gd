extends Control

@onready var log: RichTextLabel = $ScrollContainer/RichTextLabel
@onready var input: LineEdit     = $LineEdit
@onready var tip_panel: PanelContainer = $Tooltip
@onready var tip_label: Label     = $Tooltip/MarginContainer/Label

# Things your links/terms can resolve to
var glossary := {
	"look_at_sword": "A well-balanced blade. The fuller runs clean; it’s seen care.",
	"skill_Arcana":  "Arcana: knowledge of magic theory, sigils, and planar trivia."
}

func _ready() -> void:

	log.bbcode_enabled = true
	log.autowrap_mode = TextServer.AUTOWRAP_WORD
	log.scroll_following = true

	# Signals
	input.text_submitted.connect(_on_input_submitted)
	log.meta_clicked.connect(_on_log_meta_clicked)
	log.meta_hover_started.connect(_on_log_meta_hover_started)
	log.meta_hover_ended.connect(_on_log_meta_hover_ended)

	# Example content with a clickable word
	print_line("You see a [url=look_at_sword]shiny sword[/url] on the ground.")
	print_line("Skills: [url=skill_Arcana]Arcana[/url]")

	input.grab_focus()

func print_line(bbcode: String) -> void:
	log.append_text(bbcode + "\n")
	log.scroll_to_line(log.get_line_count() - 1)

# -------- Input from the LineEdit (Enter pressed) --------
func _on_input_submitted(text: String) -> void:
	var t := text.strip_edges()
	if t.is_empty():
		return
	print_line("[b]›[/b] " + t)
	input.clear()

	match t.to_lower():
		"attack":
			print_line("You attack!")
		"look":
			print_line("You take a moment to look around.")
		_:
			print_line("I don't know how to '%s' yet." % t)

# -------- Clickable links in the RichTextLabel --------
func _on_log_meta_clicked(meta: Variant) -> void:
	var key := str(meta)

	# 1) Handle explicit actions first
	match key:
		"look_at_sword":
			print_line("It’s sharp and well-kept. Might come in handy.")
			return
		# add more explicit actions here
		_:
			pass

	# 2) Fallback to glossary entry (generic info)
	if glossary.has(key):
		print_line(glossary[key])
		return

	# 3) Last-resort debug
	print_line("Clicked: %s" % key)


# -------- Hover tooltips for links --------
func _on_log_meta_hover_started(meta: Variant) -> void:
	var key := str(meta)
	if !glossary.has(key):
		return
	tip_label.text = glossary[key]
	tip_panel.global_position = get_viewport().get_mouse_position() + Vector2(12, 12)
	tip_panel.show()

func _on_log_meta_hover_ended(meta: Variant) -> void:
	tip_panel.hide()
