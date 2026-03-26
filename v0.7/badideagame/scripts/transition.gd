extends Polygon2D


func _ready() -> void:
	visible = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "modulate:a", 0.0, 1.0)


func fade_in() -> Tween:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	return tween
