extends Camera3D

@onready var qlabel: Label = $CanvasLayer/CursorSprite/QuestBackground/QuestsLabel
@onready var mlabel: Label = $CanvasLayer/CursorSprite/MoneyContainer/MoneyLabel
@onready var timer_progress: TextureProgressBar = $CanvasLayer/CursorSprite/QuestBackground/Time/TimerProgress
@onready var check: Sprite2D = $CanvasLayer/CursorSprite/Cursor/Check
@onready var time: TextureRect = $CanvasLayer/CursorSprite/QuestBackground/Time

var current_quest_name: String = ""
var max_time: float = 1.0

func _ready() -> void:
	GameManager.connect("quest_added", _on_quest_added)
	GameManager.connect("money_changed", _on_money_changed)
	GameManager.connect("quest_completed", _on_quest_completed)
	GameManager.connect("quests_updated", _update_labels)
	qlabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_update_labels()

func _process(delta: float) -> void:
	if current_quest_name != "" and GameManager.quests.has(current_quest_name):
		var quest = GameManager.quests[current_quest_name]
		timer_progress.value = max(quest["time"], 0)
		timer_progress.max_value = max_time
	else:
		timer_progress.value = 0
	if timer_progress.value == 0:
		time.texture = preload("res://assets/no_time.png")
	else:
		time.texture = preload("res://assets/time.png")

func _update_labels() -> void:
	var text = "Quests:\n"
	current_quest_name = ""

	for quest_name in GameManager.quests:
		var quest = GameManager.quests[quest_name]
		if not quest["completed"] and current_quest_name == "":
			current_quest_name = quest_name
			max_time = quest["time"] if quest["time"] > 0 else 1.0
		var status = "COMPLETED" if quest["completed"] else "X"
		text += "  [" + status + "] " + quest_name + " : "
		for scene in quest["required_items"]:
			var instance = scene.instantiate()
			var item_name = instance._name
			instance.free()
			text += " - " + item_name + "; "
		text += "\n"
	qlabel.text = text
	mlabel.text = str(GameManager.money) + "$"

func _on_quest_added(_quest_name:String):
	_update_labels()

func _on_money_changed(_amount:int):
	mlabel.text = str(GameManager.money) + "$"

func _on_quest_completed(_quest_name:String, _money:int):
	_update_labels()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(check, "modulate:a", 1.0, 0.3)
	await get_tree().create_timer(0.8).timeout
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(check, "modulate:a", 0.0, 0.3)
