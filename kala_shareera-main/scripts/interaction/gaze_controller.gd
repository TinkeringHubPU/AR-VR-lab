## GazeController – attached to XRCamera3D (or Camera3D on desktop).
## Measures dwell time on interactive objects and triggers them after 2 seconds.
## Visual feedback is provided by the ReticleManager feeling circle (2D HUD).
extends Node

signal target_focused(target: Node3D)
signal target_unfocused()
signal interaction_triggered(target: Node3D)

@export var dwell_time: float = 2.0  # Seconds
@export var raycast: RayCast3D

var current_target: Node3D = null
var hover_time: float = 0.0
var is_hovering: bool = false

func _ready() -> void:
	# Feeling circle is handled by ReticleManager autoload – nothing to set up here.
	pass

func _process(delta: float) -> void:
	if not raycast or not raycast.is_colliding():
		reset_hover()
		return

	var hit = raycast.get_collider()

	# Check if valid interactive object
	if not hit.has_method("on_gaze_interact"):
		reset_hover()
		return

	# New target detected
	if current_target != hit:
		reset_hover()
		current_target = hit
		emit_signal("target_focused", current_target)
		if current_target.has_method("on_gaze_enter"):
			current_target.on_gaze_enter()
		is_hovering = true

	# Accumulate dwell time
	if is_hovering:
		hover_time += delta

		# Update feeling circle progress (0.0 → 1.0 over dwell_time seconds)
		var progress := hover_time / dwell_time
		if ReticleManager:
			ReticleManager.set_progress(progress)

		# Trigger interaction when full
		if hover_time >= dwell_time:
			trigger_interaction()

func trigger_interaction() -> void:
	if current_target and current_target.has_method("on_gaze_interact"):
		current_target.on_gaze_interact()
		emit_signal("interaction_triggered", current_target)

	reset_hover()

func reset_hover() -> void:
	if current_target:
		if current_target.has_method("on_gaze_exit"):
			current_target.on_gaze_exit()
		emit_signal("target_unfocused")

	current_target = null
	hover_time = 0.0
	is_hovering = false
	if ReticleManager:
		ReticleManager.set_progress(0.0)
