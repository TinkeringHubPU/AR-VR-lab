extends Node

# Tutorial overlay that shows every time the main menu loads
# Positioned in front of the player, above the scroll/buttons layer

var tutorial_panel: Node3D = null
var is_showing: bool = false

func _ready():
	# Show tutorial every time the menu loads, after a brief delay
	call_deferred("_show_after_delay")

func _show_after_delay():
	await get_tree().create_timer(1.5).timeout
	show_tutorial()

func show_tutorial():
	if is_showing:
		return
	is_showing = true

	# Create the tutorial panel as a 3D overlay in scene
	tutorial_panel = Node3D.new()
	tutorial_panel.name = "TutorialOverlay"
	get_tree().current_scene.add_child(tutorial_panel)

	# Use get_camera_3d() for reliable camera lookup regardless of group
	var cam = get_viewport().get_camera_3d()
	if cam:
		var forward = -cam.global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		# 2.5m in front at eye level — small compact overlay, not full-screen
		tutorial_panel.global_position = cam.global_position + forward * 2.5
		tutorial_panel.global_position.y = cam.global_position.y
		tutorial_panel.look_at(cam.global_position)
		tutorial_panel.rotate_y(PI)
	else:
		tutorial_panel.position = Vector3(0, 1.6, 2.0)

	# === TITLE ===
	var title = Label3D.new()
	title.text = "Welcome to Kala Shareera VR"
	title.font_size = 28
	title.modulate = Color(0.95, 0.85, 0.4)
	title.outline_size = 3
	title.outline_modulate = Color(0.15, 0.1, 0.0)
	title.position = Vector3(0, 0.28, 0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.render_priority = 10
	title.no_depth_test = true
	var title_font = SystemFont.new()
	title_font.font_names = PackedStringArray(["Segoe UI", "Roboto", "Arial"])
	title_font.font_weight = 700
	title.font = title_font
	tutorial_panel.add_child(title)

	# === INSTRUCTIONS ===
	var inst1 = _create_instruction("Look at buttons to select them",     Vector3(0,  0.12, 0))
	var inst2 = _create_instruction("Hold your gaze for 2 seconds",       Vector3(0, -0.02, 0))
	var inst3 = _create_instruction("The center dot is your pointer",      Vector3(0, -0.16, 0))
	var inst4 = _create_instruction("Move your head to look around",       Vector3(0, -0.30, 0))
	for inst in [inst1, inst2, inst3, inst4]:
		tutorial_panel.add_child(inst)

	# === Dismiss hint ===
	var dismiss = Label3D.new()
	dismiss.text = "Disappears in 10 seconds..."
	dismiss.font_size = 14
	dismiss.modulate = Color(0.6, 0.55, 0.4, 0.7)
	dismiss.position = Vector3(0, -0.41, 0)
	dismiss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dismiss.render_priority = 10
	dismiss.no_depth_test = true
	tutorial_panel.add_child(dismiss)

	# === Background panel — compact 1.2 × 0.85 m ===
	var bg_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(2.0, 1.0)   # was 2.4 × 1.6
	bg_mesh.mesh = plane
	bg_mesh.rotation_degrees = Vector3(90, 0, 0)
	bg_mesh.position.z = 0.02
	bg_mesh.position.y = -0.065

	var bg_mat = StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.02, 0.01, 0.05, 0.95)
	bg_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bg_mat.emission_enabled = true
	bg_mat.emission = Color(0.08, 0.04, 0.12)
	bg_mat.emission_energy_multiplier = 0.8
	bg_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	bg_mat.render_priority = 9
	bg_mat.no_depth_test = true
	bg_mesh.set_surface_override_material(0, bg_mat)
	tutorial_panel.add_child(bg_mesh)

	# === Animate in ===
	tutorial_panel.scale = Vector3(0.01, 0.01, 0.01)
	var show_tween = create_tween()
	show_tween.set_ease(Tween.EASE_OUT)
	show_tween.set_trans(Tween.TRANS_BACK)
	show_tween.tween_property(tutorial_panel, "scale", Vector3.ONE, 0.5)

	# === Auto-dismiss after 10 seconds ===
	await get_tree().create_timer(10.0).timeout
	dismiss_tutorial()

func _create_instruction(text: String, pos: Vector3) -> Label3D:
	var label = Label3D.new()
	label.text = text
	label.font_size = 22
	label.modulate = Color(0.9, 0.9, 0.9)
	label.outline_size = 2
	label.outline_modulate = Color(0.1, 0.1, 0.1)
	label.position = pos
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.render_priority = 10
	label.no_depth_test = true  # Always visible above everything
	return label

func dismiss_tutorial():
	if tutorial_panel and is_instance_valid(tutorial_panel):
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(tutorial_panel, "scale", Vector3(0.01, 0.01, 0.01), 0.4)
		tween.tween_callback(func():
			tutorial_panel.queue_free()
			tutorial_panel = null
			is_showing = false
		)
