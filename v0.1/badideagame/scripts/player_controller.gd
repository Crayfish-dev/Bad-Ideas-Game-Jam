extends CharacterBody3D
class_name Player

@export_group("Stats")
@export var speed : float = 2.5
@export var accel : float = 8.0
@export var decel : float = 9.0
@export var gravity : float = 4.5

@export_group("Grab Settings")
@export var interaction_range : float = 4.5
@export var def_grabbing_range : float = 2.5
@export var max_grabbing_range : float = 3.5
@export var min_grabbing_range : float = 0.5
@export var grabbing_speed : float = 1

@export_group("Camera Settings")
@export var sensitivity : float = 0.002

@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera
@onready var int_ray: RayCast3D = $Neck/Camera/InteractionRay
@onready var cursor: Sprite2D = $Neck/Camera/CanvasLayer/CursorSprite/Cursor

var on_ground : bool = false
var is_moving : bool = false
var hvelocity : Vector2 = Vector2.ZERO

var bob_time : float = 0.0
var bob_speed : float = 1.0
var bob_amount : float = 0.03
var bob_walk_frequency : float = 15.0
var camera_rest_y : float = 0.0  
var grabbing_range : float = 0

var selected_item : Item = null
var hovered_timer : Item = null

func _ready() -> void:
	camera_rest_y = camera.position.y 
	int_ray.target_position.y = -interaction_range
	grabbing_range = def_grabbing_range
	cursor.position = get_viewport().get_visible_rect().size / 2

func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_hundle_input(delta)
	_hundle_item_grabbing(delta)
	_update_cursor()
	move_and_slide()
	_head_bob(delta)

func _update_cursor() -> void:
	if selected_item != null:
		cursor.frame = 3
	elif int_ray.get_collider() is Item:
		cursor.frame = 2
	else:
		cursor.frame = 0

func _hundle_input(delta : float):
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
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			neck.rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _handle_gravity(delta : float):
	on_ground = is_on_floor()
	if !on_ground:
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

func _hundle_item_grabbing(delta : float): # it's kinda of a mess, ik
	$Neck/Camera/GrabbingRangePoint.position.z = -grabbing_range
	
	if Input.is_action_pressed("away"):
		grabbing_range += grabbing_speed * delta
	if Input.is_action_pressed("near"):
		grabbing_range -= grabbing_speed * delta
	grabbing_range = clamp(grabbing_range, min_grabbing_range, max_grabbing_range)
	
	if Input.is_action_pressed("grab"):
		if selected_item == null: # grabbing
			var item = int_ray.get_collider()
			if item is Item:
				selected_item = item
				selected_item.grabbed = true
				selected_item._randomize_center() 
				selected_item.grabbing_pos = $Neck/Camera/GrabbingRangePoint.global_position
	else:
		if selected_item != null: # releasing:
			selected_item.grabbed = false
			selected_item._reset_center()
			selected_item = null
	
	if selected_item != null:
		selected_item.grabbing_pos = $Neck/Camera/GrabbingRangePoint.global_position
