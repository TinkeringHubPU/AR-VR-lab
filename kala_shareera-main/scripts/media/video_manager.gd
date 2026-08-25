extends Node

@export_group("Media References")
@export var video_screen_mesh: MeshInstance3D
@export var video_player: VideoStreamPlayer
@export var auto_play_video_name: String = ""

var current_video: String = ""
var is_playing: bool = false

signal video_started(video_name: String)
signal video_finished(video_name: String)

func _ready():
	if video_player:
		video_player.finished.connect(_on_video_finished)

	# Make the video screen self-lit so it's visible in the dark void_space environment
	if video_screen_mesh:
		var mat = video_screen_mesh.get_active_material(0)
		if mat and mat is StandardMaterial3D:
			mat.albedo_color = Color(1, 1, 1, 1)
			mat.emission_enabled = true
			mat.emission = Color(1, 1, 1)
			mat.emission_energy_multiplier = 0.05  # Subtle — video texture provides brightness

	if auto_play_video_name != "":
		get_tree().create_timer(0.5).timeout.connect(func(): play_video(auto_play_video_name))

func play_video(video_name: String):
	var video_path = "res://assets/videos/%s.ogv" % video_name
	
	var stream = null
	if FileAccess.file_exists(video_path):
		stream = load(video_path)
		
	if stream == null:
		push_warning("Video missing or invalid: " + video_path + ". Falling back to icon.svg temporary texture.")
		if video_screen_mesh:
			var active_mat = video_screen_mesh.get_active_material(0)
			if active_mat and active_mat is StandardMaterial3D:
				active_mat.albedo_texture = load("res://icon.svg")
		is_playing = true
		emit_signal("video_started", video_name)
		# Create a timer to spoof video finishing after 5 seconds
		get_tree().create_timer(5.0).timeout.connect(_on_video_finished)
		return
	
	current_video = video_name
	
	if video_player:
		video_player.position = Vector2(-4000, -4000) # Hide from 2D screen!
		video_player.stream = stream
		video_player.play()
	
	# Apply to 3D screen
	if video_screen_mesh:
		var active_mat = video_screen_mesh.get_active_material(0)
		if active_mat and active_mat is StandardMaterial3D and video_player:
			active_mat.albedo_texture = video_player.get_video_texture()
	
	is_playing = true
	emit_signal("video_started", video_name)

func _on_video_finished():
	is_playing = false
	emit_signal("video_finished", current_video)
	
	# Auto-return to menu or show continue option
	if UIManager != null:
		UIManager.show_completion_prompt()
