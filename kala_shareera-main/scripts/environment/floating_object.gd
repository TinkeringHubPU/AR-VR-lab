extends Node3D

@export var float_amplitude: float = 0.05
@export var float_speed: float = 1.0
@export var enable_rotation: bool = false
@export var rotation_speed: float = 0.2

var initial_position: Vector3
var time_offset: float = 0.0

func _ready():
	initial_position = position
	time_offset = randf() * TAU  # Random start phase

func _process(delta):
	var time = Time.get_ticks_msec() / 1000.0
	
	# Vertical float
	position.y = initial_position.y + sin(time * float_speed + time_offset) * float_amplitude
	
	# Optional slow rotation
	if enable_rotation:
		rotation.y += rotation_speed * delta
