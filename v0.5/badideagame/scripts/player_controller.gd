extends CharacterBody3D
class_name Player

@export_group("Stats")
@export var speed : float = 2.5
@export var accel : float = 8.0
@export var decel : float = 9.0
@export var gravity : float = 4.5

@export_group("Grab Settings")
@export var interaction_range : float = 3.0
@export var def_grabbing_range : float = 3.0
@export var max_grabbing_range : float = 3.0
@export var min_grabbing_range : float = 0.5
@export var grabbing_speed : float = 1

@export_group("Camera Settings")
@export var sensitivity : float = 0.002

@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera
@onready var int_ray: RayCast3D = $Neck/Camera/InteractionRay
@onready var cursor: Sprite2D = $Neck/Camera/CanvasLayer/CursorSprite/Cursor
@onready var title: Label = $Neck/Camera/CanvasLayer/CursorSprite/Cursor/Title
@onready var description: Label = $Neck/Camera/CanvasLayer/CursorSprite/Cursor/Description
@onready var dialogue_container: TextureRect = $Neck/Camera/CanvasLayer/CursorSprite/DialogueContainer
@onready var dialogue_label: Label = $Neck/Camera/CanvasLayer/CursorSprite/DialogueContainer/DialogueLabel

var on_ground : bool = false
var is_moving : bool = false
var ui_open : bool = false
var hvelocity : Vector2 = Vector2.ZERO

var _dialogue_tween : Tween = null
var _current_line_length : int = 0
var bob_time : float = 0.0
var bob_speed : float = 1.0
var bob_amount : float = 0.03
var bob_walk_frequency : float = 15.0
var camera_rest_y : float = 0.0  
var grabbing_range : float = 0

var selected_item : Item = null
var seeing_obj : Node3D = null

func _ready() -> void:
	GameManager.enabled = true
	camera_rest_y = camera.position.y 
	int_ray.target_position.y = -interaction_range
	grabbing_range = def_grabbing_range
	dialogue_container.position.x = get_viewport().get_visible_rect().size.x / 2
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_hundle_input(delta)
	_hundle_item_grabbing(delta)
	_hundle_interactions()
	_update_cursor()
	move_and_slide()
	_head_bob(delta)

func _update_cursor() -> void:
	if ui_open:
		cursor.position = get_viewport().get_mouse_position() + Vector2(10,10)
		cursor.frame = 1
		description.text = ""
		title.text = ""
	else:
		cursor.position = get_viewport().get_visible_rect().size / 2
		if int_ray.get_collider() is NPC:
			title.text = int_ray.get_collider()._name
			description.text = "talk to client [E]"
			cursor.frame = 4
			return
		if int_ray.get_collider() is Interactable:
			if int_ray.get_collider() is Shop:
				title.text = "Random Crack"
				description.text = "open shop [E]"
			cursor.frame = 4
			return
		if int_ray.get_collider() is Item:
			title.text = int_ray.get_collider()._name
			description.text = int_ray.get_collider()._description
		elif selected_item != null:
			title.text = selected_item._name
			description.text = selected_item._description
		else:
			description.text = ""
			title.text = ""
	
		if selected_item != null:
			cursor.frame = 3
		elif int_ray.get_collider() is Item:
			cursor.frame = 2
		else:
			cursor.frame = 0

func _hundle_input(delta : float):
	if ui_open: return
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	hvelocity = Vector2(velocity.x, velocity.z)
	is_moving = hvelocity.length() > 0.5
	if direction: 
		velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, decel * delta)
		velocity.z = lerp(velocity.z, 0.0, decel * delta)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("next"):
		if _dialogue_tween and _dialogue_tween.is_running():
			_dialogue_tween.stop()
			dialogue_label.visible_characters = _current_line_length
	if ui_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if Input.is_action_just_pressed("ui_cancel"):
			ui_open = false
		return
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		ui_open = true
	
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			neck.rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func _handle_gravity(delta : float):
	on_ground = is_on_floor()
	if not on_ground:
		velocity.y += -gravity * delta
	else:
		velocity.y = 0

func _head_bob(delta: float) -> void:
	if on_ground and is_moving:
		bob_time += bob_walk_frequency * delta
		camera.position.y = camera_rest_y + sin(bob_time) * bob_amount
	else:
		bob_time = 0.0 
		camera.position.y = lerp(camera.position.y, camera_rest_y, bob_speed * delta)

func _hundle_interactions():
	seeing_obj = null

	var collider = int_ray.get_collider()
	if collider != null:
		seeing_obj = collider

	if Input.is_action_just_pressed("interact"):
		if seeing_obj is NPC:
			seeing_obj.clicked(self)
		if seeing_obj is Shop:
			seeing_obj.use(self)

func _hundle_item_grabbing(delta : float):
	if ui_open:
		selected_item = null
		return
	$Neck/Camera/GrabbingRangePoint.position.z = -grabbing_range
	
	if Input.is_action_pressed("away"):
		grabbing_range += grabbing_speed * delta
	if Input.is_action_pressed("near"):
		grabbing_range -= grabbing_speed * delta
	grabbing_range = clamp(grabbing_range, min_grabbing_range, max_grabbing_range)
	
	if Input.is_action_pressed("grab"):
		if selected_item == null:
			var item = int_ray.get_collider()
			if item is Item:
				selected_item = item
				selected_item.grabbed = true
				selected_item._randomize_center() 
				selected_item.grabbing_pos = $Neck/Camera/GrabbingRangePoint.global_position
	else:
		if selected_item != null:
			selected_item.grabbed = false
			selected_item._reset_center()
			selected_item = null
	
	if selected_item != null:
		selected_item.grabbing_pos = $Neck/Camera/GrabbingRangePoint.global_position

# --- Dialogue functions ---
func play_dialogue(_name: String, dialogue: Array[String], speed: float = 2.0) -> void:
	await _show_dialogue_page(_name, dialogue, 0, speed)

func _show_dialogue_page(_name: String, dialogue: Array[String], index: int, speed: float) -> void:
	if index >= dialogue.size():
		dialogue_container.visible = false
		await get_tree().create_timer(0.2).timeout 
		return
	
	dialogue_container.visible = true
	var line = _name + ": \n" + dialogue[index]
	dialogue_label.text = line
	dialogue_label.visible_characters = _name.length() + 2
	_current_line_length = line.length()
	
	_dialogue_tween = create_tween()
	_dialogue_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	_dialogue_tween.tween_property(dialogue_label, "visible_characters", _current_line_length, speed)
	
	await get_tree().create_timer(0.2).timeout
	while not Input.is_action_just_pressed("next"):
		await get_tree().process_frame 

	await _show_dialogue_page(_name, dialogue, index + 1, speed)
