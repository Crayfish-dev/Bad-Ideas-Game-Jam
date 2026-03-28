extends StaticBody3D

@export var box : PackedScene
@export var special_box : PackedScene
@export var node_array : Array[Node3D] = [$Box1, $Box2, $Box3, $Box4]
@export var box_spawn_percentage : float = 45.0

func _ready() -> void:
	for node in node_array:
		if randi_range(0, 100) <= box_spawn_percentage:
			var b = box.instantiate()
			node.get_parent().add_child(b)
			b.closed = true
			b.global_position = node.global_position
			b.rotation = node.rotation
	var special_b = special_box.instantiate()
	$LongBox.get_parent().add_child(special_b)
	special_b.closed = true
	special_b.global_position = $LongBox.global_position
	special_b.rotation.y = $LongBox.rotation.y
