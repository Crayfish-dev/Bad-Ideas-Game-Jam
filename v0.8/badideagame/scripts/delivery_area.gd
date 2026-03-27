extends Area3D
class_name DeliveryArea

signal delivered

func _ready() -> void:
	GameManager.delivery_area = self

func _on_body_entered(body: Box) -> void:
	GameManager._turn_in_boxes(GameManager.active_quest, [body])
	emit_signal("delivered")
