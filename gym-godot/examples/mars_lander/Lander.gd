extends RigidBody

var jetStrength : float = 0.08
var lightEnergy : float = 0.15

func _ready() -> void:
	hide_all_flames()

func impulse(engine_id : String) -> void:
	hide_all_flames()
	if engine_id == "AuxX":
		$MeshFlameAuxX.visible = true
		$LightAuxX.light_energy = lightEnergy
		apply_impulse(transform.basis.xform($MeshFlameAuxX.transform.origin), -transform.basis.x*jetStrength)
	elif engine_id == "AuxXn":
		$MeshFlameAuxXn.visible = true
		$LightAuxXn.light_energy = lightEnergy
		apply_impulse(transform.basis.xform($MeshFlameAuxXn.transform.origin), transform.basis.x*jetStrength)
	elif engine_id == "AuxZ":
		$MeshFlameAuxZ.visible = true
		$LightAuxZ.light_energy = lightEnergy
		apply_impulse(transform.basis.xform($MeshFlameAuxZ.transform.origin), -transform.basis.z*jetStrength)
	elif engine_id == "AuxZn":
		$MeshFlameAuxZn.visible = true
		$LightAuxZn.light_energy = lightEnergy
		apply_impulse(transform.basis.xform($MeshFlameAuxZn.transform.origin), transform.basis.z*jetStrength)
	elif engine_id == "Main":
		$MeshFlameMain.visible = true
		$LightMain.light_energy = lightEnergy*2
		apply_impulse(transform.basis.xform($MeshFlameMain.transform.origin), 4*transform.basis.y*jetStrength)
	elif engine_id == "None":
		pass
		
func hide_all_flames() -> void :
	$MeshFlameAuxX.visible = false
	$MeshFlameAuxXn.visible = false
	$MeshFlameAuxZ.visible = false
	$MeshFlameAuxZn.visible = false
	$MeshFlameMain.visible = false
	$LightAuxX.light_energy = 0
	$LightAuxXn.light_energy = 0
	$LightAuxZ.light_energy = 0
	$LightAuxZn.light_energy = 0
	$LightMain.light_energy = 0
