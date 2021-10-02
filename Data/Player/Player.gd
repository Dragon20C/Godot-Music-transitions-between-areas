extends KinematicBody

var mouse_sen : float = 0.1
var speed : int = 12
var rotation_speed :  float = 12
var jump_force : int = 8
var accel : int = 0
var air_accel : int = 1
var norm_accel : int = 6
var gravity_force : float = 9.8
var velocity : Vector3 = Vector3()
var movement:  Vector3 = Vector3()
var gravity_vec : Vector3 = Vector3()
var snap : Vector3 = Vector3()
onready var camera_base = get_node("Head")

const JOY_DEADZONE = 0.2
const JOY_AXIS_RESCALE = 1.0/(1.0-JOY_DEADZONE)
const JOY_ROTATION_MULTIPLIER = 200.0 * PI / 180.0



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass


func _unhandled_input(event):
	if Input.is_action_pressed("ui_cancel"): #if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_connected_joypads().size() == 0:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				rotate_y(deg2rad(-event.relative.x * mouse_sen))
				camera_base.rotate_x(deg2rad(-event.relative.y * mouse_sen))
	
func camera_rotation(delta):
		#get_tree().quit()
	#if Input.get_connected_joypads().size() > 0:
		#var right_stick_axis = Vector2(Input.get_joy_axis(0,JOY_AXIS_2), Input.get_joy_axis(0,JOY_AXIS_3))
		#rotate_y(deg2rad(-right_stick_axis.angle() * mouse_sen))
		#print(right_stick_axis.angle())
		# var joypad_vec = Vector2()
	if Input.get_connected_joypads().size() == 0:
			return
			
	var xAxis = Input.get_joy_axis(0, JOY_AXIS_2)
	if abs(xAxis) > JOY_DEADZONE:
		if xAxis >0:
			xAxis = (xAxis-JOY_DEADZONE) * JOY_AXIS_RESCALE
		else:
			xAxis = (xAxis+JOY_DEADZONE) * JOY_AXIS_RESCALE
		rotate_object_local(Vector3.UP, -xAxis * delta * JOY_ROTATION_MULTIPLIER)
			
	var yAxis = Input.get_joy_axis(0, JOY_AXIS_3)
	if abs(yAxis) > JOY_DEADZONE:
		if yAxis >0:
			yAxis = (yAxis-JOY_DEADZONE) * JOY_AXIS_RESCALE
		else:
			yAxis = (yAxis+JOY_DEADZONE) * JOY_AXIS_RESCALE
		$Head.rotate_object_local(Vector3.RIGHT, -yAxis * delta * JOY_ROTATION_MULTIPLIER/1.5)
		#$Head.rotation.x = clamp(rotation.x, -1.0, 1.0)

		

func _physics_process(delta):
	camera_rotation(delta)
	camera_base.rotation.x = clamp(camera_base.rotation.x,deg2rad(-80),deg2rad(80))
	var input = get_input()
	apply_gravity(delta)
	apply_movement(input,delta)
	
	movement = move_and_slide_with_snap(movement,snap,Vector3.UP)
			
func get_input():
	var input_vector = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	input_vector.z = Input.get_action_strength("backward") - Input.get_action_strength("forward") 
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	return input_vector.rotated(Vector3.UP,h_rot).normalized() if input_vector.length() > 1 else input_vector.rotated(Vector3.UP,h_rot)


func apply_movement(input,delta):
	#if Input.is_action_pressed("sprint") and is_on_floor() and input != Vector3.ZERO:
	#	speed = 10
	#else:
	#	speed = 8
		
	velocity = velocity.linear_interpolate(input * speed,accel * delta)
	movement = velocity + gravity_vec

func apply_gravity(delta):
	if is_on_floor():
		snap = -get_floor_normal()
		accel = norm_accel
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = air_accel
		gravity_vec += Vector3.DOWN * gravity_force * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump_force
		
	if Input.is_action_just_released("jump") and gravity_vec.y > jump_force / 2:
		gravity_vec = Vector3.UP * jump_force / 2
