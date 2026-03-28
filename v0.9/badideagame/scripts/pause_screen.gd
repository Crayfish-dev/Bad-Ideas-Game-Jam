extends Control

@export var pl : Player
@onready var transition: Polygon2D = $"../CursorSprite/Transition"

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and not pl.shop_ui.visible:
		visible = not visible
		pl.ui_open = visible
		get_tree().paused = visible
		if visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed() -> void:
	visible = not visible
	pl.ui_open = visible
	get_tree().paused = visible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_leave_pressed() -> void:
	get_tree().paused = false
	await transition.fade_in().finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	GameManager.money = 10
	GameManager.quests.clear()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	await transition.fade_in().finished
	GameManager.money = 10
	GameManager.quests.clear()
	get_tree().reload_current_scene()
