extends Node3D

func _ready() -> void:
	var platform = OS.get_name()

	if platform == "Android":
		var xr_interface = XRServer.find_interface("OpenXR")
		if xr_interface and (xr_interface.is_initialized() or xr_interface.initialize()):
			print("Universal Rig: OpenXR ready – booting Quest Rig.")
			_spawn_rig("res://scenes/player/quest_camera_rig.tscn")
		else:
			# Android phone – main menu needs flat (non-stereo) rendering with touch
			# Modules use vr_camera_rig (spawned by universal_rig when scene is a module)
			var scene_path = get_tree().current_scene.scene_file_path
			if "main_menu" in scene_path:
				print("Universal Rig: Android Phone (Main Menu) – flat camera + touch.")
				_spawn_rig("res://scenes/player/desktop_camera_rig.tscn")
			else:
				print("Universal Rig: Android Phone (Module) – Gyro VR stereo.")
				_spawn_rig("res://scenes/player/vr_camera_rig.tscn")
	else:
		# Desktop / Editor
		print("Universal Rig: Desktop – booting Desktop Rig.")
		_spawn_rig("res://scenes/player/desktop_camera_rig.tscn")

func _spawn_rig(path: String) -> void:
	var rig_scene = load(path)
	if rig_scene:
		var instance = rig_scene.instantiate()
		add_child(instance)
	else:
		push_error("Universal Rig: Failed to load rig at ", path)
