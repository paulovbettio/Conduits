extends SpringArm3D

## Platformer-style orbit camera controller.
## Attach to a SpringArm3D node with a Camera3D as a child.
## Point the SpringArm3D's target (Spring Length) toward your character.

@export_group("Rotation")
@export var mouse_sensitivity: float = 0.3
@export var gamepad_sensitivity: float = 2.5
@export var invert_y: bool = false

@export_group("Pitch Limits")
@export var pitch_min: float = -20.0  ## Degrees. How far down the camera can look.
@export var pitch_max: float = 60.0   ## Degrees. How far up the camera can look.

@export_group("Zoom")
@export var zoom_speed: float = 1.0
@export var zoom_min: float = 1.5
@export var zoom_max: float = 8.0
@export var zoom_smooth: float = 10.0

var _yaw: float = 0.0    # Horizontal rotation (around Y axis)
var _pitch: float = 20.0 # Vertical rotation
var _target_zoom: float  # Smoothed zoom target


func _ready() -> void:
	# Detach from parent rotation so the arm rotates independently
	set_as_top_level(true)
	_target_zoom = spring_length
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw   -= event.relative.x * mouse_sensitivity
		_pitch += event.relative.y * mouse_sensitivity * (1.0 if invert_y else -1.0)
		_pitch  = clamp(_pitch, pitch_min, pitch_max)

	# Mouse zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = clamp(_target_zoom - zoom_speed, zoom_min, zoom_max)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = clamp(_target_zoom + zoom_speed, zoom_min, zoom_max)

		# Toggle mouse capture with Escape
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	_apply_rotation()
	_apply_zoom(delta)

func _apply_rotation() -> void:
	# Keep the SpringArm3D positioned on the parent (your character node)
	if get_parent() is Node3D:
		global_position = (get_parent() as Node3D).global_position

	global_rotation_degrees = Vector3(_pitch, _yaw, 0.0)


func _apply_zoom(delta: float) -> void:
	spring_length = lerpf(spring_length, _target_zoom, zoom_smooth * delta)
