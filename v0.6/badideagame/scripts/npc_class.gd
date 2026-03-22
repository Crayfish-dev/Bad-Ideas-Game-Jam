extends CharacterBody3D
class_name NPC

signal finished

const NPC_FOLDER : String = "res://scenes/npcs/"

@export var _name : String = "NPC"
@export var quest_name : String = "NPC quest"
@export var random_items : bool = true
@export var item_count : int = 3
@export var items : Array[PackedScene] = []
@export var quest_time : float = 180.0
@export var starting_point : Vector3 = Vector3(7.0, 0.0, -3.0)
@export var stopping_point : Vector3 = Vector3(0.0,0.0,-2.4)
@export var leaving_point : Vector3 = Vector3(-11.0,0.0,-3.0)

@export_group("Lines of Dialogue")
@export var start_dialogue : Array[String] = ["hey, this is the start of a new quest!"]
@export var during_dialogue : Array[String] = ["are you doing the quest i gave you?"]
@export var delivery_dialogue : Array[String] = ["finally!", "see ya!"]
@export var late_delivery_dialogue : Array[String] = ["you took too long!", "i won't give you money."]
@export var late_dialogue : Array[String] = ["YOU'RE LATE!!!!"]

var quest_given : bool = false
var delivered : bool = false
var late : bool = false
var leaving : bool = false
var _is_talking : bool = false

func _ready():
	position = starting_point
	GameManager.quest_is_late.connect(_on_quest_late)
	GameManager.delivery_area.connect("delivered", is_delivered)

func _process(delta: float) -> void:
	if not quest_given:
		position = position.lerp(stopping_point, 0.5)

func clicked(pl : Player) -> void:
	if _is_talking:
		return 

	_is_talking = true

	if not delivered:
		if late:
			await pl.play_dialogue(_name, late_dialogue,0.5)
			start_leaving()
		elif not quest_given:
			await pl.play_dialogue(_name, start_dialogue)
			GameManager._add_quest(quest_name, items, quest_time, random_items)
			quest_given = true
		else:
			await pl.play_dialogue(_name, during_dialogue)
	else:
		if late:
			await pl.play_dialogue(_name, late_delivery_dialogue,0.5)
		else:
			await pl.play_dialogue(_name, delivery_dialogue, 0.5)

	_is_talking = false
	if delivered:
		start_leaving()

func start_leaving() -> void:
	if leaving:
		return
	leaving = true
	_leave_with_tween()

func _on_quest_late(q_name:String):
	if q_name == quest_name:
		late = true

func is_delivered():
	delivered = true

func _leave_with_tween() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", leaving_point, 3.0)
	tween.finished.connect(_leave)

func _leave() -> void:
	var dir = DirAccess.open(NPC_FOLDER)
	if not dir:
		return

	dir.list_dir_begin()
	var files := []

	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir():
			continue
		files.append(file_name)

	dir.list_dir_end()

	if files.size() == 0:
		return

	var random_file = files[randi() % files.size()]
	var scene_path = NPC_FOLDER + random_file 

	var scene = load(scene_path)
	var instance = scene.instantiate()
	get_parent().add_child(instance)
	instance.position = starting_point
	queue_free()
