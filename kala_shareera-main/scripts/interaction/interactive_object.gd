extends StaticBody3D
class_name InteractiveObject

@export_group("Interaction Settings")
@export var action_id: String = ""
@export var label_text: String = ""
@export_color_no_alpha var hover_color: Color = Color(0.5, 0.8, 1.0)

@export var main_icon: Texture2D

@onready var mesh: MeshInstance3D = $MeshInstance3D if has_node("MeshInstance3D") else null
@onready var label_3d: Label3D = $Label3D if has_node("Label3D") else null

var original_material: Material
var is_hovered: bool = false

func _ready():
	collision_layer = 2

	if mesh:
		original_material = StandardMaterial3D.new()
		if main_icon:
			original_material.albedo_texture = main_icon
			original_material.albedo_color = Color(0.85, 0.85, 0.85, 1.0)  # FIX: not pure white
			original_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		else:
			original_material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			original_material.albedo_color = Color(0.5, 0.55, 0.75, 1.0)
		original_material.roughness = 0.25

		# Soft self-emission so icons read clearly without lighting
		original_material.emission_enabled = true
		original_material.emission = Color(0.28, 0.28, 0.32)
		original_material.emission_energy_multiplier = 1.4

		mesh.set_surface_override_material(0, original_material)

	if label_text != "":
		if label_3d:
			label_3d.text = label_text
		else:
			var new_label = Label3D.new()
			new_label.text = label_text
			new_label.position.y = -0.65
			new_label.position.z = 0.1
			new_label.font_size = 36
			var modern_font = SystemFont.new()
			modern_font.font_names = PackedStringArray(["Segoe UI", "Roboto", "Helvetica Neue", "Arial"])
			modern_font.font_weight = 700
			new_label.font = modern_font
			new_label.outline_size = 2
			new_label.modulate = Color(1.0, 1.0, 1.0)
			add_child(new_label)

func on_gaze_enter():
	is_hovered = true
	if mesh and original_material and original_material is BaseMaterial3D:
		original_material.emission_enabled = true
		original_material.emission = hover_color
		original_material.emission_energy_multiplier = 2.0  # was 4.0 – reduced to avoid harsh flash
		original_material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)

	if AudioManager != null:
		AudioManager.play_hover()

	if mesh:
		var tween = create_tween()
		tween.tween_property(mesh, "scale", Vector3(1.05, 1.05, 1.05), 0.15).set_trans(Tween.TRANS_SINE)

func on_gaze_exit():
	is_hovered = false
	if mesh and original_material and original_material is BaseMaterial3D:
		original_material.emission = Color(0.28, 0.28, 0.32)
		original_material.emission_energy_multiplier = 1.4
		original_material.albedo_color = Color(0.85, 0.85, 0.85, 1.0)

	if mesh:
		var tween = create_tween()
		tween.tween_property(mesh, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_SINE)

func on_gaze_interact():
	if AudioManager != null:
		AudioManager.play_click()
	print("Interacted with: ", action_id)
