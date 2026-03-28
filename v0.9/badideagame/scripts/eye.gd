extends Node3D

var player : Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	$Eye.look_at(player.global_position + Vector3(0, 1.5, 0))
