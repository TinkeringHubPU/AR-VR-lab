extends XROrigin3D

var xr_interface: XRInterface
var _spawn_position: Vector3

func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("Quest Rig: OpenXR confirmed – enabling XR viewport.")
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		push_error("Quest Rig: OpenXR not initialized – headset may not be connected.")
	
	_spawn_position = global_position

func _physics_process(_delta: float) -> void:
	# Lock player to spawn position – prevents walking outside the gurukul.
	# Only restrict X/Z; Y stays free for floor-level calibration.
	global_position = Vector3(_spawn_position.x, global_position.y, _spawn_position.z)
