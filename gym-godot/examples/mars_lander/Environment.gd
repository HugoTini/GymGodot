extends Spatial

# Reward function weights
export(float) var distanceCostWeight = 5
export(float) var tiltCostWeight = 1
# Negative reward for crashing
export(float) var crashCost = 100
# Positive reward for landing the four lander legs
export(float) var landedStepReward = 5

# Consider crashed when outside of these absolute limits
var max_height : int = 14
var max_z : int = 8
var max_x : int = 8

# Crash / landing reward store for the current frame
var extraReward : float = 0
# Becomes true if lander crash
var isDone : bool = false

# Last frame's lander projection onto vertical (used to compute tilt speed)
var last_auxX_to_vertical : float = 0
var last_auxZ_to_vertical : float = 0

func _ready() -> void:
	#randomize()
	reset()

func apply_action(action : Array) -> void :
	if action[0] == 0 :
		$Lander.impulse("Main")
	elif action[0] == 1 :
		$Lander.impulse("AuxX")
	elif action[0] == 2 :
		$Lander.impulse("AuxXn")
	elif action[0] == 3 :
		$Lander.impulse("AuxZ")
	elif action[0] == 4 :
		$Lander.impulse("AuxZn")
	elif action[0] == 5 :
		$Lander.impulse("None")

func get_observation() -> Array :
	# Lander world position
	var landerX : float = $Lander.global_transform.origin.x
	var landerY : float = $Lander.global_transform.origin.y
	var landerZ : float = $Lander.global_transform.origin.z
	# Lander speed
	var landerX_dt : float = $Lander.linear_velocity.x
	var landerY_dt : float = $Lander.linear_velocity.y
	var landerZ_dt : float = $Lander.linear_velocity.z
	# Lander jet's normal projection to vertical
	var auxX_to_vertical : float = $Lander.global_transform.basis.x[1]
	var auxZ_to_vertical : float = $Lander.global_transform.basis.z[1]
	# Lander jet's normal projection to vertical speed
	var auxX_to_vertical_dt : float = (auxX_to_vertical - last_auxX_to_vertical)
	var auxZ_to_vertical_dt : float = (auxZ_to_vertical - last_auxZ_to_vertical)
	last_auxX_to_vertical = auxX_to_vertical
	last_auxZ_to_vertical = auxZ_to_vertical
	
	return [landerX, landerY, landerZ, 
			landerX_dt, landerY_dt, landerZ_dt,
			auxX_to_vertical, auxZ_to_vertical,
			auxX_to_vertical_dt, auxZ_to_vertical_dt]

func get_reward() -> float :
	# Reward for approaching the landing area (~ in [0,1])
	var dist : float = $Lander/MeshFlameMain.global_transform.origin.distance_to(Vector3(0,0,0))
	var distReward : float = 1 - ( dist / sqrt( pow(max_height,2)+sqrt(pow(2*max_z,2))+sqrt(pow(2*max_x,2)) ) )
	# Reward for staying vertical (in [-1,1])
	var vertical_projection = $Lander.global_transform.basis.y[1]
	# Weighted total reward
	var reward = distReward*distanceCostWeight + vertical_projection*tiltCostWeight + extraReward
	# Reinit extra reward for landing
	extraReward = 0
	return reward

func reset() -> void :
	$CameraAnimation.stop(true)
	$CameraAnimation.play('camera_path')
	isDone = false
	extraReward = 0
	$Lander.hide_all_flames()
	$Lander.set_identity()
	# Random X / Z coordinates within crash limits. Y at fixed height.
	var rand_pos_x = rand_range(-max_x+2, max_x-2)
	var rand_pos_z = rand_range(-max_z+2, max_z-2)
	$Lander.global_transform.origin = Vector3(rand_pos_x, max_height-3, rand_pos_z)
	# Add random rotation around random direction
	var rand_x = rand_range(0,1)
	var rand_y = rand_range(0,1)
	var rand_z = rand_range(0,1)
	var angle = rand_range(-PI,PI)
	$Lander.global_transform.basis = $Lander.global_transform.basis.rotated(Vector3(rand_x,rand_y,rand_z).normalized(), angle)
	# Reset speed to zero
	$Lander.linear_velocity = Vector3(0,0,0)
	$Lander.angular_velocity = Vector3(0,0,0)
	# Update last AuxZ & AuxY projection to vertical
	last_auxX_to_vertical = $Lander.global_transform.basis.x[1]
	last_auxZ_to_vertical = $Lander.global_transform.basis.z[1]
	_physics_process(0)

func is_done() -> bool :
	return isDone

func _physics_process(_delta: float) -> void:
	# Lander center position limits
	if $Lander.global_transform.origin.y > max_height :
		isDone = true
		extraReward -= crashCost
	elif abs($Lander.global_transform.origin.x) > max_x :
		isDone = true
		extraReward -= crashCost
	elif abs($Lander.global_transform.origin.z) > max_z :
		isDone = true
		extraReward -= crashCost
	elif $Lander.global_transform.origin.y < 0 :
		isDone = true
		extraReward -= crashCost

# Uncomment this code & disable GymGodot node to control with arrow keys
#	if Input.is_action_pressed("ui_left"): 
#		$Lander.impulse("AuxX")
#	elif Input.is_action_pressed("ui_right"): 
#		$Lander.impulse("AuxXn")
#	elif Input.is_action_pressed("ui_up"): 
#		$Lander.impulse("AuxZ")
#	elif Input.is_action_pressed("ui_down"): 
#		$Lander.impulse("AuxZn")
#	elif Input.is_action_pressed("ui_accept"): 
#		$Lander.impulse("Main")
#	else :
#		$Lander.hide_all_flames()
	
	if $LandingArea.get_overlapping_areas().size() == 4 :
		extraReward += landedStepReward
		print('Landed full')
	elif $LandingArea.get_overlapping_areas().size() >= 1 :
		print('Landed ' + str($LandingArea.get_overlapping_areas().size()) + '/4')
		extraReward += $LandingArea.get_overlapping_areas().size() * (landedStepReward / 4)
