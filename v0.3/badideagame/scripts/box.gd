extends Item
class_name Box

var can_close : bool = false
var closed : bool = false
var bodies_inside : Array = []

func _process(delta: float) -> void:
	if !closed:
		$Lid.visible = false
		$LidShape.disabled = true
		if !can_close:
			_description = "something is in the way, this box can't be closed"
		else:
			_description = "E to close the box"
	else:
		$Lid.visible = true
		$LidShape.disabled = false
		_description = "E to open the box"
	if Input.is_action_just_pressed("interact") and grabbed:
		if closed:
			closed = false
		else:
			if can_close:
				closed = true

func _on_out_area_body_entered(body: Item) -> void:
	can_close = false

func _on_out_area_body_exited(body: Item) -> void:
	can_close = true

func _on_inside_area_body_entered(body: Item) -> void:
	if body not in bodies_inside:
		if body != self:
			bodies_inside.append(body)

func get_items():
	return bodies_inside

func remove():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property(self, "scale", Vector3(0,0,0), 0.5)
	
	for body in bodies_inside:
		tween.tween_property(body, "scale", Vector3(0,0,0), 0.5)
	
	tween.set_parallel(false)
	tween.tween_callback(func():
		for body in bodies_inside:
			body.queue_free()
		queue_free()
	)


func _on_inside_area_body_exited(body: Item) -> void:
	if body in bodies_inside:
		bodies_inside.erase(body)
