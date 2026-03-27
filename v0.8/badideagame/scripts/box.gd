extends Item
class_name Box

var can_close : bool = true
var closed : bool = false
var bodies_inside : Array = []
var _size = 1.5

func _ready() -> void:
	_custom_ready()
	$InsideArea.connect("body_entered", _on_inside_area_body_entered)
	$InsideArea.connect("body_exited", _on_inside_area_body_exited)
	$OutArea.connect("body_entered", _on_out_area_body_entered)
	$OutArea.connect("body_exited", _on_out_area_body_exited)

func _process(delta: float) -> void:
	_custom_process(delta)
	if !closed:
		$Lid.visible = false
		$LidShape.disabled = true
		if !can_close:
			_description = "something is in the way, this box can't be closed"
		else:
			_description = "close the box [E]"
	else:
		$Lid.visible = true
		$LidShape.disabled = false
		_description = "open the box [E]"
	if Input.is_action_just_pressed("interact") and grabbed:
		if closed:
			closed = false
		else:
			if can_close:
				closed = true

func _on_out_area_body_entered(body: Item) -> void:
	if body != self:
		can_close = false

func _on_out_area_body_exited(body: Item) -> void:
	if body != self:
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

func _custom_process(delta : float) -> void:
	pass

func _custom_ready() -> void:
	pass

func _on_inside_area_body_exited(body: Item) -> void:
	if body in bodies_inside:
		bodies_inside.erase(body)
