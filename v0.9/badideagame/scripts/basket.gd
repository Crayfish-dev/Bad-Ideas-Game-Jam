extends StaticBody3D

func _on_enter_area_body_entered(body: PaperBall) -> void:
	if body.linear_velocity.y < -0.0:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "scale", scale * 1.2, 0.3)
		tween.tween_property(self, "scale", Vector3(1,1,1), 0.15)
