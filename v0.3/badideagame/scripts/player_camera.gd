extends Camera3D

@onready var qlabel: Label = $CanvasLayer/CursorSprite/QuestBackground/QuestsLabel
@onready var mlabel: Label = $CanvasLayer/CursorSprite/MoneyContainer/MoneyLabel

func _ready() -> void:
	GameManager.connect("quest_added", _on_quest_added)
	GameManager.connect("money_changed", _on_money_changed)
	_update_labels()

func _update_labels() -> void:
	var text = "Quests:\n"
	for quest_name in GameManager.quests:
		var quest = GameManager.quests[quest_name]
		var status = "COMPLETED" if quest["completed"] else "X"
		text += "  [" + status + "] " + quest_name + " : "
		for scene in quest["required_items"]:
			var instance = scene.instantiate()
			var item_name = instance._name
			instance.free()
			text += "    - " + item_name + "; "
	qlabel.text = text
	mlabel.text = str(GameManager.money) + "$"

func _on_quest_added(_quest_name: String):
	_update_labels()

func _on_money_changed(_amount: int):
	_update_labels()
