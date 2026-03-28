extends Control

@onready var cursor: Sprite2D = $Cursor
@onready var transition: Polygon2D = $Transition
@onready var music: AudioStreamPlayer3D = $"../Music"

func _process(delta: float) -> void:
	cursor.position = get_local_mouse_position()

func _on_play_pressed() -> void:
	$"../Map/Bell".ring_bell()
	await transition.fade_in().finished
	get_tree().change_scene_to_file("res://scenes/main_map.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
