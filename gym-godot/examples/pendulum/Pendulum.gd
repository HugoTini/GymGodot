extends RigidBody

func apply_torque(strength):
	apply_torque_impulse(Vector3(strength,0,0))

func get_angle() -> float:
	var pendulum_vec : Vector3 = get_node('Cylinder2').global_transform.origin - \
								 get_node('Cylinder1').global_transform.origin
	var angle : float = Vector3(0,1,0).angle_to(pendulum_vec)
	angle = angle * sign(get_node('Cylinder2').global_transform.origin.z)
	return angle
