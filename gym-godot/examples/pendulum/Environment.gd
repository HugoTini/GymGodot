extends Spatial

var currentAction : float = 0
var theta : float = 0
var lastTheta : float = 0
var theta_dt : float = 0

func _ready() -> void:
	reset()

func _physics_process(_delta: float) -> void:
	# Uncomment this code & disable GymGodot node to control with mouse buttons
#	if Input.is_mouse_button_pressed(1):
#		apply_action([2])
#	if Input.is_mouse_button_pressed(2):
#		apply_action([-2])
	pass

func apply_action(action : Array) -> void :
	currentAction = clip(action[0], -2, 2)
	$Pendulum.apply_torque(currentAction)
	# Scale arrow according to torque force
	$Arrow.scale.x = abs(currentAction/2)
	$Arrow.scale.z = currentAction/2

func get_observation() -> Array :
	theta = $Pendulum.get_angle()
	# Unwrap the angle if needed
	if sign(theta) != sign(lastTheta):
		if (theta > PI/2):
			lastTheta = lastTheta + 2*PI
		if (theta < -PI/2):
			lastTheta = lastTheta - 2*PI
	# Compute angular velocity
	theta_dt = (theta - lastTheta)*10
	lastTheta = theta
	return [cos(theta), sin(theta), theta_dt]

func get_reward() -> float :
	var cost = theta*theta + 0.1*theta_dt*theta_dt + 0.001*currentAction*currentAction
	return -cost

func reset() -> void :
	var rand_rot = rand_range(-PI,PI)
	$Pendulum.translate(Vector3(0,6,0))
	$Pendulum.rotation = Vector3(rand_rot,0,0)
	$Pendulum.translate(Vector3(0,-6,0))
	$Pendulum.linear_velocity = Vector3(0,0,0)
	$Pendulum.angular_velocity = Vector3(0,0,0)
	lastTheta = $Pendulum.get_angle()
	_physics_process(0)

func is_done() -> bool :
	return false

func clip(value : float, minValue : float, maxValue : float) -> float :
	if value > maxValue :
		value = maxValue
	elif value < minValue :
		value = minValue
	return value
