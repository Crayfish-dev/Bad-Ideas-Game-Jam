extends Item
class_name Box

var can_close : bool = false
var closed : bool = false
var bodies_inside : Array = []

func _ready() -> void:
	$Model.material_override = StandardMaterial3D.new()
	_update_color()

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
			closed = true

func _update_color() -> void:
	var mat := $Model.material_override as StandardMaterial3D

func _on_out_area_body_entered(body: Item) -> void:
	can_close = false

func _on_out_area_body_exited(body: Item) -> void:
	can_close = true


func _on_inside_area_body_entered(body: Item) -> void:
	if body not in bodies_inside:
		if body != self:
			bodies_inside.append(body)


func _on_inside_area_body_exited(body: Item) -> void:
	if body in bodies_inside:
		bodies_inside.erase(body)
