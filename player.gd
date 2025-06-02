extends CharacterBody3D

@export var mouse_sensitivity: float = 0.002
@export var ACCELERATION: float = 0.1
@export var DECELEATION: float = 0.4
@export var AIR_ACCELERATION: float = 0.05
@export var AIR_CONTROL_MULTIPLIER: float = 0.5
@export var gravity: float = 9.8
@export var fall_multiplier: float = 2.0

@onready var head: Node3D = $Head
@onready var eye_camera: Camera3D = $Head/EyeCamera

const SPEED = 5.0
const BASE_JUMP_VELOCITY = 3.5

var fall_time: float = 0.0

func _physics_process(delta: float) -> void:
	if is_on_floor():
		fall_time = 0.0
	else:
		fall_time += delta
		var fall_force = gravity + (fall_time * gravity * fall_multiplier)
		velocity.y -= fall_force * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = BASE_JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (eye_camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		var target_speed = SPEED
		var accel = ACCELERATION
		if not is_on_floor():
			target_speed *= AIR_CONTROL_MULTIPLIER
			accel = AIR_ACCELERATION
		velocity.x = lerp(velocity.x, direction.x * target_speed, accel)
		velocity.z = lerp(velocity.z, direction.z * target_speed, accel)
	else:
		var deaccel = DECELEATION if is_on_floor() else AIR_ACCELERATION
		velocity.x = move_toward(velocity.x, 0, deaccel)
		velocity.z = move_toward(velocity.z, 0, deaccel)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var relative = event.relative * mouse_sensitivity
		head.rotate_y(-relative.x)
		eye_camera.rotate_x(-relative.y)
		eye_camera.rotation.x = clamp(eye_camera.rotation.x, deg_to_rad(-40), deg_to_rad(40))
