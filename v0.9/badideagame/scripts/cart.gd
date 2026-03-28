extends Node3D

func _ready() -> void:
	await get_tree().create_timer(20.0).timeout
	queue_free()

func _process(delta: float) -> void:
	global_position.x += 0.08
