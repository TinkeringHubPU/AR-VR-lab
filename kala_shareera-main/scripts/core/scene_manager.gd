extends Node

signal scene_loading(scene_name: String)
signal scene_loaded(scene_name: String)

var scenes = {
	"menu": "res://scenes/menu/main_menu.tscn",
	"credits": "res://scenes/menu/credits_scene.tscn",
	"intro": "res://scenes/modules/intro_module.tscn",
	"mamsadhara": "res://scenes/modules/mamsadhara_module.tscn",
	"raktadhara": "res://scenes/modules/raktadhara_module.tscn",
	"medodhara": "res://scenes/modules/medodhara_module.tscn",
	"sleshmadhara": "res://scenes/modules/sleshmadhara_module.tscn",
	"purishadhara": "res://scenes/modules/purishadhara_module.tscn",
	"pittadhara": "res://scenes/modules/pittadhara_module.tscn",
	"shukradhara": "res://scenes/modules/shukradhara_module.tscn",
}

var current_scene: String = ""
var previous_scene: String = ""

func load_scene(scene_name: String):
	if not scenes.has(scene_name):
		push_error("Scene not found: " + scene_name)
		return
	
	emit_signal("scene_loading", scene_name)
	
	previous_scene = current_scene
	current_scene = scene_name
	
	# Fade to black first
	if UIManager != null:
		UIManager.show_loading()
	
	# Wait for the fade-in to complete before switching scenes
	await get_tree().create_timer(1.2).timeout
	
	var error = get_tree().change_scene_to_file(scenes[scene_name])
	if error != OK:
		push_error("Failed to change scene")
	
	# Hold the loading screen a bit so the user reads the message
	await get_tree().create_timer(1.0).timeout
	
	emit_signal("scene_loaded", scene_name)
	
	if UIManager != null:
		UIManager.hide_loading()

func _is_android_phone() -> bool:
	if OS.get_name() != "Android":
		return false
	var xr = XRServer.find_interface("OpenXR")
	return not (xr and xr.is_initialized())

func load_module(module_name: String):
	if not scenes.has(module_name):
		push_error("Scene not found: " + module_name)
		return

	if _is_android_phone():
		# Android phone: show loading screen and wait 20s for user to insert phone into VR headset
		emit_signal("scene_loading", module_name)
		if UIManager != null:
			UIManager.show_loading()
		# Give user 20 seconds to put phone into cardboard/VR headset
		await get_tree().create_timer(20.0).timeout
		previous_scene = current_scene
		current_scene = module_name
		get_tree().change_scene_to_file(scenes[module_name])
		await get_tree().create_timer(1.0).timeout
		emit_signal("scene_loaded", module_name)
		if UIManager != null:
			UIManager.hide_loading()
	else:
		load_scene(module_name)

func return_to_menu():
	load_scene("menu")

func return_to_previous():
	if previous_scene != "":
		load_scene(previous_scene)
	else:
		return_to_menu()
