extends Node3D

var tmr : float = 5.0
@export var perc : int = 40

func _process(delta: float) -> void:
	tmr = clamp(tmr, 0.0, 5.0)
	if tmr > 0:
		tmr-=delta
	else:
		var chance : int = randi_range(0, 100)
		if chance < perc:
			var cart = preload("res://scenes/map_components/cart.tscn")
			var c = cart.instantiate()
			add_child(c)
			c.global_position = global_position
			c.scale.y *= -1
			c.scale.z *= -1
		tmr = 5.0
