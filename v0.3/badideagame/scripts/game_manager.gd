extends Node
# THIS IS A TUTORIAL MONSTER
const DAY_LENGTH: float = 260.0
const NIGHT_THRESHOLD: float = 0.5
const ITEMS_FOLDER: String = "res://scenes/items/"

const MONEY_PER_ITEM: int = 10
const BOX_PENALTY: int = 5

signal day_started(day_count: int)
signal night_started(day_count: int)
signal money_changed(new_amount: int)
signal quest_completed(quest_name: String, money_earned: int)
signal quest_added(quest_name: String)

var enabled : bool = false # does nothing
var quests: Dictionary = {}

var _money: int = 0
var money: int:
	get: return _money
	set(value):
		_money = value
		emit_signal("money_changed", _money)

func _ready() -> void:
	_add_quest("name", [])

func _add_quest(quest_name: String, items: Array[Item], random: bool = true, random_count: int = 3) -> void:
	if quests.has(quest_name):
		push_warning("Quest already exists: " + quest_name)
		return

	var required_items: Array = []

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

		if all_files.is_empty():
			push_error("No items found in: " + ITEMS_FOLDER)
			return

		all_files.shuffle()
		for i in range(min(random_count, all_files.size())): # min() somehow fixed all the script
			var scene: PackedScene = load(all_files[i])
			if scene:
				required_items.append(scene)
	else:
		required_items = items

	quests[quest_name] = {
		"required_items": required_items,
		"completed": false,
		"random": random,
	}

	_spawn_required_items(required_items)
	emit_signal("quest_added", quest_name)
	print("Quest added: ", quest_name, " / Items required: ", required_items.size())

func _turn_in_boxes(quest_name: String, boxes: Array[Box]) -> void:
	if not quests.has(quest_name):
		push_warning("Quest not found: " + quest_name)
		return

	var quest: Dictionary = quests[quest_name]

	if quest["completed"]:
		push_warning("Quest already completed: " + quest_name)
		return

	var all_turned_in: Array = []
	for box in boxes:
		if box is Box:
			if box.closed:
				for item in box.get_items():
					all_turned_in.append(item)
				box.remove()

	var required: Array = quest["required_items"]

	var matched: int = 0
	var unmatched_required: Array = required.duplicate()
	for item in all_turned_in:
		for i in range(unmatched_required.size()):
			var item_scene = item.get_meta("source_scene", null)
			if item_scene != null and unmatched_required[i] == item_scene:
				matched += 1
				unmatched_required.remove_at(i)
				break

	if matched < required.size():
		print("Quest failed: missing ", required.size() - matched, " items")
		return

	var earned: int = (matched * MONEY_PER_ITEM) - (boxes.size() * BOX_PENALTY)
	earned = max(earned, 0)

	quest["completed"] = true
	money += earned
	quests.erase(quest)

	print("Quest completed: ", quest_name)
	print("Items matched: ", matched, " / Boxes used: ", boxes.size(), " / Earned: $", earned)
	emit_signal("quest_completed", quest_name, earned)

func _spawn_required_items(required: Array):
	for scene in required:
		var i = scene.instantiate()
		i.set_meta("source_scene", scene)
		get_tree().current_scene.add_child(i)
		i.global_position = Vector3(0, 2, 0)

func _reset() -> void:
	money = 0
	quests.clear()
