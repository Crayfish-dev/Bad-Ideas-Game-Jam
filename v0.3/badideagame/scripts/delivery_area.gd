extends Area3D
class_name DeliveryArea


func _on_body_entered(body: Box) -> void:
	GameManager._turn_in_boxes("name", [body])
