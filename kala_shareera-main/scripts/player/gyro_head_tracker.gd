extends Node3D

@export var touch_sensitivity: float = 0.005
@export var pitch_limit: float = 85.0
var current_rotation: Vector3 = Vector3.ZERO

func _ready():
	current_rotation = rotation

func _input(event):
	# 1. GUARANTEED TOUCH FALLBACK
	# _input captures events globally before any UI CanvasLayer blocks them!
	if event is InputEventScreenDrag:
		current_rotation.y -= event.relative.x * touch_sensitivity
		current_rotation.x -= event.relative.y * touch_sensitivity
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		current_rotation.y -= event.relative.x * touch_sensitivity
		current_rotation.x -= event.relative.y * touch_sensitivity

func _process(delta):
	# 2. ACCELEROMETER PITCH
	# Input.get_gravity() uses the accelerometer (which the Oppo F19 absolutely has).
	var grav: Vector3 = Input.get_gravity()
	if grav.length() > 0.5:
		var norm_grav = grav.normalized()
		# In landscape mode, Z tracks whether the phone is upright or flat
		var target_pitch = asin(norm_grav.z)
		current_rotation.x = lerp(current_rotation.x, target_pitch, 0.1)

	# 3. GYROSCOPE YAW (If mysteriously available)
	var gyro: Vector3 = Input.get_gyroscope()
	if gyro.length() > 0.01:
		current_rotation.y -= gyro.y * 2.0 * delta

	# Clamp and Apply
	current_rotation.x = clamp(current_rotation.x, deg_to_rad(-pitch_limit), deg_to_rad(pitch_limit))
	rotation = rotation.lerp(current_rotation, 0.5)
