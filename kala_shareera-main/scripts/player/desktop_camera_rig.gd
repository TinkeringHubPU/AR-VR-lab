extends Node3D

@onready var camera: Camera3D = $Camera3D
var hovered_object: Node3D = null

func _ready() -> void:
	# CRITICAL: dynamically added Camera3D needs make_current() in Godot 4.
	camera.make_current()
	# Register for tutorial/about panel positioning
	camera.add_to_group("vr_camera")
	print("Desktop Rig: Camera active at ", camera.global_position)

func _physics_process(_delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * 1000

	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 2

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		if hovered_object:
			if hovered_object.has_method("on_gaze_exit"):
				hovered_object.on_gaze_exit()
			hovered_object = null
	else:
		var hit = result.collider
		if hit != hovered_object:
			if hovered_object and hovered_object.has_method("on_gaze_exit"):
				hovered_object.on_gaze_exit()
			hovered_object = hit
			if hovered_object.has_method("on_gaze_enter"):
				hovered_object.on_gaze_enter()

func _input(event: InputEvent) -> void:
	var triggered := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		triggered = true
	elif event is InputEventScreenTouch and not event.pressed:  # tap release = interact
		triggered = true
	if triggered and hovered_object and hovered_object.has_method("on_gaze_interact"):
		hovered_object.on_gaze_interact()
