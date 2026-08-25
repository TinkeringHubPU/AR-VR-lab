extends Node3D

# ─────────────────────────────────────────────────────────────────────────────
#  Kala Shareera – Credits Scene
#  Scrolls credit text upward like movie credits in front of the player.
#  Add future credits to _get_credits_data() only – no scene editing needed.
# ─────────────────────────────────────────────────────────────────────────────

const SCREEN_Z      := -3.5    # metres in front of camera
const SCROLL_SPEED  := 0.18    # metres per second (increase for faster scroll)
const LINE_SPACING  := 0.19    # vertical gap between lines (metres)
const EYE_Y         := 1.6     # desktop eye / VR headset height

var _scroller: Node3D          # parent of all credit Label3Ds – moves upward
var _back_label: Label3D       # "◄ Back to Menu" hint
var _finished := false

# ─── Entry point ────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_stars()
	_build_scroller()
	_build_back_hint()

# ─── Per-frame scroll ────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if _finished or not _scroller:
		return
	_scroller.position.y += SCROLL_SPEED * delta
	# Once every line has scrolled past eye level, auto-return to menu
	if _scroller.position.y > EYE_Y + 3.0:
		_go_back()

# ─── Input: any key / click / tap returns to menu ───────────────────────────
func _input(event: InputEvent) -> void:
	if _finished:
		return
	var triggered := false
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		triggered = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		triggered = true
	elif event is InputEventScreenTouch and not event.pressed:
		triggered = true
	if triggered:
		_go_back()

func _go_back() -> void:
	if _finished:
		return
	_finished = true
	SceneManager.return_to_menu()

# ─────────────────────────────────────────────────────────────────────────────
#  CREDITS DATA  ← Edit this function to add/remove credits
# ─────────────────────────────────────────────────────────────────────────────
func _get_credits_data() -> Array:
	return [
		["logo",    "✦  KALA SHAREERA VR  ✦"],
		["tagline", "Ayurvedic Anatomy in Virtual Reality"],
		["space",   ""],
		["space",   ""],

		["section", "━━━  PROJECT  ━━━"],
		["space",   ""],
		["role",    "Concept & Direction"],
		["name",    "Vansh"],
		["space",   ""],
		["role",    "Development"],
		["name",    "Vansh"],
		["space",   ""],
		["role",    "3D Environment"],
		["name",    "Vansh"],
		["space",   ""],

		["section", "━━━  CONTENT  ━━━"],
		["space",   ""],
		["role",    "Ayurvedic Anatomy Source"],
		["name",    "Charaka Samhita – Sharira Sthana"],
		["space",   ""],
		["role",    "Kala (Membranes) Referenced"],
		["name",    "Mamsa Dhara Kala"],
		["name",    "Rakta Dhara Kala"],
		["name",    "Medo Dhara Kala"],
		["name",    "Sleshma Dhara Kala"],
		["name",    "Purisha Dhara Kala"],
		["name",    "Pitta Dhara Kala"],
		["name",    "Shukra Dhara Kala"],
		["space",   ""],

		["section", "━━━  TECHNOLOGY  ━━━"],
		["space",   ""],
		["role",    "VR Platform"],
		["name",    "Meta Quest 3 / 3S"],
		["role",    "Cross-Platform"],
		["name",    "Android VR  ◈  Desktop"],
		["space",   ""],

		["section", "━━━  SPECIAL THANKS  ━━━"],
		["space",   ""],
		["name",    "Faculty & Mentors"],
		["name",    "Department of Sharira Rachana"],
		["name",    "All Beta Testers"],
		["space",   ""],
		["space",   ""],

		["section", "━━━━━━━━━━━━━━━━━━━━━━━━━━"],
		["space",   ""],
		["logo",    "Version  1.0.0"],
		["tagline", "© 2026  All Rights Reserved"],
		["space",   ""],
		["space",   ""],
		["tagline", "Tap / Click anywhere to return"],
	]

# ─────────────────────────────────────────────────────────────────────────────
#  BUILD  SCROLLER
# ─────────────────────────────────────────────────────────────────────────────
func _build_scroller() -> void:
	_scroller = Node3D.new()
	_scroller.name = "CreditsScroller"
	add_child(_scroller)

	var data := _get_credits_data()

	# Count total height so we know where to start (below camera)
	var total_height := data.size() * LINE_SPACING
	# Start below the bottom of the viewport (–2 m below eye level)
	var start_y := EYE_Y - 2.5

	_scroller.position = Vector3(0, start_y, SCREEN_Z)

	# Build from bottom to top (first entry ends up at top)
	var y := -total_height  # start well below; each entry moves it up
	for entry in data:
		var kind: String = entry[0]
		var text: String = entry[1]

		if kind == "space":
			y += LINE_SPACING * 0.5
			continue

		var label := Label3D.new()
		label.text = text
		label.render_priority = 5
		label.no_depth_test = true
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.billboard = BaseMaterial3D.BILLBOARD_DISABLED

		match kind:
			"logo":
				label.font_size = 38
				label.modulate   = Color(1.0, 0.85, 0.35)   # gold
				label.outline_size = 4
				label.outline_modulate = Color(0.3, 0.15, 0.0)
				var f := SystemFont.new()
				f.font_names = PackedStringArray(["Segoe UI", "Roboto", "Arial"])
				f.font_weight = 800
				label.font = f
			"section":
				label.font_size = 22
				label.modulate   = Color(0.7, 0.85, 1.0)    # cool blue
				label.outline_size = 2
			"tagline":
				label.font_size = 20
				label.modulate   = Color(0.85, 0.85, 0.9)
				label.outline_size = 1
			"role":
				label.font_size = 17
				label.modulate   = Color(0.65, 0.75, 0.9, 0.85)
			"name":
				label.font_size = 20
				label.modulate   = Color(0.95, 0.95, 0.95)
				label.outline_size = 1

		label.position = Vector3(0, y, 0)
		_scroller.add_child(label)
		y += LINE_SPACING

# ─────────────────────────────────────────────────────────────────────────────
#  BACK HINT  (fixed at bottom of view)
# ─────────────────────────────────────────────────────────────────────────────
func _build_back_hint() -> void:
	_back_label = Label3D.new()
	_back_label.text = "◄  Press Esc / Tap anywhere to return"
	_back_label.font_size = 16
	_back_label.modulate = Color(0.6, 0.6, 0.65, 0.75)
	_back_label.render_priority = 6
	_back_label.no_depth_test = true
	_back_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Fixed in world space below eye level
	_back_label.position = Vector3(0, EYE_Y - 1.2, SCREEN_Z)
	add_child(_back_label)

# ─────────────────────────────────────────────────────────────────────────────
#  STAR BACKGROUND  (simple procedural dots)
# ─────────────────────────────────────────────────────────────────────────────
func _build_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var stars := Node3D.new()
	stars.name = "StarField"
	add_child(stars)

	for i in 220:
		var mesh_inst := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = rng.randf_range(0.008, 0.022)
		sphere.height = sphere.radius * 2.0
		sphere.radial_segments = 4
		sphere.rings = 2
		mesh_inst.mesh = sphere

		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var bright := rng.randf_range(0.5, 1.0)
		mat.albedo_color = Color(bright, bright, rng.randf_range(bright * 0.85, 1.0))
		mat.emission_enabled = true
		mat.emission = mat.albedo_color
		mat.emission_energy_multiplier = rng.randf_range(0.5, 2.0)
		mesh_inst.set_surface_override_material(0, mat)

		mesh_inst.position = Vector3(
			rng.randf_range(-8.0, 8.0),
			rng.randf_range(-2.0, 10.0),
			rng.randf_range(-25.0, -6.0)
		)
		stars.add_child(mesh_inst)
