extends CanvasLayer

var fade_rect: ColorRect
var loading_label: Label
var loading_sublabel: Label
var is_transitioning: bool = false

# Loading messages for variety
var loading_messages = [
	"Preparing your learning space...",
	"Opening the ancient scrolls...",
	"Entering the realm of Kala Shareera...",
	"Awakening Ayurvedic wisdom...",
]

func _ready():
	layer = 100  # Always on top
	
	# Create fade overlay
	fade_rect = ColorRect.new()
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.03, 0.01, 0.08, 0)  # Dark purple-black, start transparent
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_rect)
	
	# Create loading label (main text)
	loading_label = Label.new()
	loading_label.set_anchors_preset(Control.PRESET_CENTER)
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	loading_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	loading_label.custom_minimum_size = Vector2(800, 100)
	loading_label.position = Vector2(-400, -50)
	loading_label.add_theme_font_size_override("font_size", 32)
	loading_label.add_theme_color_override("font_color", Color(0.85, 0.7, 0.3))  # Golden
	loading_label.add_theme_color_override("font_shadow_color", Color(0.4, 0.3, 0.1, 0.5))
	loading_label.add_theme_constant_override("shadow_offset_x", 2)
	loading_label.add_theme_constant_override("shadow_offset_y", 2)
	loading_label.text = ""
	loading_label.visible = false
	loading_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(loading_label)
	
	# Create subtle sub-label
	loading_sublabel = Label.new()
	loading_sublabel.set_anchors_preset(Control.PRESET_CENTER)
	loading_sublabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_sublabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loading_sublabel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	loading_sublabel.grow_vertical = Control.GROW_DIRECTION_BOTH
	loading_sublabel.custom_minimum_size = Vector2(600, 50)
	loading_sublabel.position = Vector2(-300, 30)
	loading_sublabel.add_theme_font_size_override("font_size", 18)
	loading_sublabel.add_theme_color_override("font_color", Color(0.6, 0.55, 0.4, 0.7))
	loading_sublabel.text = "Kala Shareera VR"
	loading_sublabel.visible = false
	loading_sublabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(loading_sublabel)

func show_loading():
	if is_transitioning:
		return
	is_transitioning = true
	
	# Pick a random loading message
	loading_label.text = loading_messages[randi() % loading_messages.size()]
	
	# Fade to dark
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.4).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		loading_label.visible = true
		loading_sublabel.visible = true
		# Fade in the text
		loading_label.modulate = Color(1, 1, 1, 0)
		loading_sublabel.modulate = Color(1, 1, 1, 0)
		var text_tween = create_tween()
		text_tween.set_parallel(true)
		text_tween.tween_property(loading_label, "modulate:a", 1.0, 0.3)
		text_tween.tween_property(loading_sublabel, "modulate:a", 1.0, 0.5)
	)

func hide_loading():
	# Fade out text first, then fade out overlay
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(loading_label, "modulate:a", 0.0, 0.2)
	tween.tween_property(loading_sublabel, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(func():
		loading_label.visible = false
		loading_sublabel.visible = false
	)
	tween.chain().tween_property(fade_rect, "color:a", 0.0, 0.5).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func():
		is_transitioning = false
	)

func show_completion_prompt():
	print("UI: Video complete. Returning to menu in 3 seconds...")
	# Show a brief "Module Complete" overlay before returning
	loading_label.text = "Module Complete ✓"
	loading_label.visible = true
	loading_label.modulate = Color(1, 1, 1, 0)
	loading_sublabel.text = "Returning to menu..."
	loading_sublabel.visible = true
	loading_sublabel.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween()
	# Fade in overlay + text
	tween.set_parallel(true)
	tween.tween_property(fade_rect, "color:a", 0.85, 0.5)
	tween.tween_property(loading_label, "modulate:a", 1.0, 0.5)
	tween.tween_property(loading_sublabel, "modulate:a", 1.0, 0.7)
	# Wait 2 seconds
	tween.chain().tween_interval(2.0)
	# Then go back to menu
	tween.chain().tween_callback(func(): SceneManager.return_to_menu())
