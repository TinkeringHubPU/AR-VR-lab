extends Node3D

# Main menu controller — handles ambient music and tutorial
# Attach this to the MainMenu root node

func _ready():
	# Start ambient music when entering the main menu
	if AudioManager != null:
		AudioManager.start_ambient_music()

func _exit_tree():
	# Stop music when leaving the menu (entering a module)
	if AudioManager != null:
		AudioManager.stop_ambient_music()
