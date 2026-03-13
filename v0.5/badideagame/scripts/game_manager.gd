extends Node

const DAY_LENGTH: float = 260.0
const NIGHT_THRESHOLD: float = 0.5
const ITEMS_FOLDER: String = "res://scenes/items/"

const MONEY_PER_ITEM: int = 10
const BOX_PENALTY: int = 5
const MIN_ON_TIME_REWARD: int = 2

signal day_started(day_count: int)
signal night_started(day_count: int)
signal money_changed(new_amount: int)
signal quest_completed(quest_name: String, money_earned: int)
signal quest_added(quest_name: String)
signal quest_is_late(quest_name: String)
signal quests_updated

var enabled : bool = false
var quests: Dictionary = {}
var active_quest: String = ""

var delivery_area : DeliveryArea = null

var _money: int = 0
var money: int:
	get: return _money
	set(value):
		_money = value
		emit_signal("money_changed", _money)

func _process(delta: float) -> void:
	active_quest = ""
	for quest_name in quests.keys():
		var q = quests[quest_name]
		if q["completed"]:
			continue

		if active_quest == "":
			active_quest = quest_name

		q["time"] -= delta

		if q["time"] <= 0 and not q.get("late", false):
			q["late"] = true
			emit_signal("quest_is_late", quest_name)
			emit_signal("quests_updated")

func _add_quest(quest_name: String, items: Array[PackedScene], time : float = 60.0, random: bool = true, random_count: int = 3) -> void:
	if quests.has(quest_name):
		push_warning("Quest already exists: " + quest_name)
		return

	var required_items: Array = []

	for item in items:
		required_items.append(item)

	if random:
		var dir := DirAccess.open(ITEMS_FOLDER)
		if dir == null:
			push_error("Cannot open items folder: " + ITEMS_FOLDER)
			return

		var all_files: Array = []

		dir.list_dir_begin()
		var file_name := dir.get_next()

		while file_name != "":
			if file_name.ends_with(".tscn"):
				all_files.append(ITEMS_FOLDER + file_name)
			file_name = dir.get_next()

		dir.list_dir_end()

		all_files.shuffle()

		for i in range(min(random_count, all_files.size())):
			var scene: PackedScene = load(all_files[i])
			if scene:
				required_items.append(scene)

	var potential = required_items.size() * MONEY_PER_ITEM

	quests[quest_name] = {
		"required_items": required_items,
		"delivered": [],
		"completed": false,
		"random": random,
		"time": time,
		"potential_money": potential,
		"late": false
	}

	_spawn_required_items(required_items)

	emit_signal("quest_added", quest_name)
	emit_signal("quests_updated")

func _turn_in_boxes(quest_name: String, boxes: Array) -> void:

	if not quests.has(quest_name):
		push_warning("Quest not found: " + quest_name)
		return

	var quest: Dictionary = quests[quest_name]

	if quest["completed"]:
		return

	var required:Array = quest["required_items"]
	var delivered:Array = quest["delivered"]

	var penalty:int = boxes.size() * BOX_PENALTY

	for box in boxes:
		if box is Box and box.closed:

			for item in box.get_items():

				var item_scene = item.get_meta("source_scene", null)
				if item_scene == null:
					continue

				if item_scene in required and not item_scene in delivered:

					delivered.append(item_scene)

					var earned = MONEY_PER_ITEM
					earned -= penalty
					earned = max(earned,0)

					money += earned

			box.remove()

	if delivered.size() >= required.size():

		quest["completed"] = true

		var bonus:int = 0

		if not quest["late"]:
			bonus = max(MIN_ON_TIME_REWARD,0)

		money += bonus

		print("Quest completed: ", quest_name)

		emit_signal("quest_completed", quest_name, bonus)
		emit_signal("quests_updated")

		_remove_quest_later(quest_name)

func _remove_quest_later(quest_name:String) -> void:

	await get_tree().create_timer(1.0).timeout

	if quests.has(quest_name):
		quests.erase(quest_name)
		emit_signal("quests_updated")

func _spawn_required_items(required: Array):

	for scene in required:

		await get_tree().create_timer(0.5).timeout

		var i = scene.instantiate()

		i.set_meta("source_scene", scene)

		get_tree().current_scene.add_child(i)

		i.global_position = Vector3(0,2,0)

func _reset() -> void:

	money = 0
	quests.clear()
	active_quest = ""

	emit_signal("quests_updated")
