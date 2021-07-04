extends Spatial

var isDone : bool = false
var cartPosition : float = 0.0
var lastCartPosition : float = 0.0
var poleAngle : float = 0.0
var lastPoleAngle : float = 0.0

func _ready() -> void:
	reset()

func apply_action(action : Array) -> void :
	if action[0] == 0 :
		$Cart.apply_impulse($Cart.global_transform.origin, Vector3(0,0,-2))
	else :
		$Cart.apply_impulse($Cart.global_transform.origin, Vector3(0,0,2))

func get_observation() -> Array :
	var currentCartPosition = cartPosition
	var cartVelocity = currentCartPosition - lastCartPosition
	var currentPoleAngle = poleAngle
	var poleVelocity = currentPoleAngle - lastPoleAngle
	lastCartPosition = cartPosition
	lastPoleAngle = poleAngle
	return [currentCartPosition, cartVelocity, currentPoleAngle, poleVelocity]

func get_reward() -> float :
	return 1.0

func reset() -> void :
	isDone = false
	$Cart.linear_velocity = Vector3(0,0,0)
	$Cart.transform.origin = Vector3(0,0,0)
	$Pendulum.linear_velocity = Vector3(0,0,0)
	$Pendulum.transform.origin = Vector3(0,6,0)
	$Pendulum.rotation = Vector3(0,0,0)
	$Pendulum.angular_velocity = Vector3(0,0,0)
	lastCartPosition = 0
	lastPoleAngle = 0
	_physics_process(0)
	
func is_done() -> bool :
	return isDone

func _physics_process(delta: float) -> void:
	# Uncomment this code & disable GymGodot node to control with mouse buttons
	#if Input.is_mouse_button_pressed(1):
	#	apply_action([0])
	#if Input.is_mouse_button_pressed(2):
	#	apply_action([1])
	# If cartpole z-position > 40 or < 40 then episode ends
	cartPosition = $Cart.global_transform.origin.z
	if abs(cartPosition) > 40 :
		isDone = true
	# If pendulum angle is > pi/8 or < pi/8 then episode ends
	var pendulum_vec = $Pendulum.get_node('Cylinder1').global_transform.origin - \
						$Pendulum.get_node('Cylinder2').global_transform.origin
	poleAngle = Vector3(0,1,0).angle_to(pendulum_vec)
	poleAngle = poleAngle * sign($Pendulum.get_node('Cylinder1').global_transform.origin.z - \
															$Cart.global_transform.origin.z)
	if abs(poleAngle) > PI/8 :
		isDone = true
