## ReticleManager – autoload singleton that controls the gaze feeling circle HUD.
## The actual drawing is done by GazeCircle (_draw-based custom Control) inside
## the GazeReticle CanvasLayer scene which is instantiated here at runtime.
extends CanvasLayer

const RETICLE_SCENE := "res://scenes/ui/gaze_reticle.tscn"

var _gaze_circle: Control = null   # the GazeCircle node inside the scene

func _ready() -> void:
	layer = 50  # Below UIManager (100) so transitions still overlay it
	_spawn_reticle()

func _spawn_reticle() -> void:
	if not FileAccess.file_exists(RETICLE_SCENE):
		push_warning("ReticleManager: gaze_reticle.tscn not found, reticle disabled.")
		return
	var packed = load(RETICLE_SCENE)
	if packed == null:
		push_warning("ReticleManager: failed to load gaze_reticle.tscn.")
		return
	var instance = packed.instantiate()
	add_child(instance)
	# Locate the GazeCircle node (Control with set_progress method)
	_gaze_circle = instance.get_node_or_null("Center/GazeCircle")
	if _gaze_circle == null:
		push_warning("ReticleManager: GazeCircle node not found in reticle scene.")

## Called by gaze_controller.gd every frame with value 0.0–1.0.
func set_progress(value: float) -> void:
	if _gaze_circle and _gaze_circle.has_method("set_progress"):
		_gaze_circle.set_progress(value)

## Convenience helpers kept for backwards compatibility.
func set_hover(_active: bool) -> void:
	pass  # Handled by colour change inside GazeCircle.set_progress()

func reset() -> void:
	set_progress(0.0)
