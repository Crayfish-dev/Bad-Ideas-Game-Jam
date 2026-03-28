extends Item
class_name PaperBall

var air_time : float = 0.0

func _process(delta: float) -> void:
	var pl = GameManager.player
	air_time = clamp(air_time, 0.0, 0.8)
	if air_time > 0:
		can_be_grabbed = false
		air_time -= delta
	else:
		can_be_grabbed = true
	if Input.is_action_just_pressed("interact") and grabbed:
		pl.selected_item = null
		grabbed = false
		var throw_force = 2.5
		linear_velocity = Vector3.ZERO
		apply_central_impulse(-pl.camera.global_transform.basis.z * throw_force)
		air_time = 0.8
