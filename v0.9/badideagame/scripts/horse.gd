extends Node3D

@export var legs : Array[Node3D] = []

func _process(delta: float) -> void:
	for node in legs:
		node.rotation.x -= 0.1
