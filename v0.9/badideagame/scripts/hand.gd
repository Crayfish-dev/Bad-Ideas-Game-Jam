extends TextureRect

@export var plr : Player
@export var offset : Vector2 = Vector2.ZERO

@export var idle_texture : Texture2D
@export var walk_texture : Texture2D
@export var grab_texture : Texture2D
@export var pointing_texture : Texture2D

@export var bob_amount : float = 12.0
@export var bob_speed : float = 6.0

@export var grab_shake_speed : float = 30.0
@export var grab_shake_amount : float = 5.0
@onready var cursor: Sprite2D = $"../Cursor"
@onready var player: Player = $"../../../../.."

var bob_time : float = 0.0
var shake_time : float = 0.0
var rest_position : Vector2

func _ready() -> void:
	rest_position = position
	position = get_viewport().get_visible_rect().size + offset

func _process(delta: float) -> void:
	if player.ui_open:
		cursor.frame = 1
		cursor.position = get_viewport().get_mouse_position() + Vector2(10,10)
		self.visible = false
	if plr.selected_item != null:
		texture = grab_texture
	elif plr.seeing_obj is NPC:
		texture = pointing_texture
	elif plr.is_moving:
		texture = walk_texture
	else:
		texture = idle_texture

	if plr.selected_item != null:
		_grab_shake(delta)
	else:
		_hand_bob(delta)

func _grab_shake(delta: float) -> void:
	shake_time += delta * grab_shake_speed
	var x_offset = sin(shake_time) * grab_shake_amount
	position = rest_position + Vector2(x_offset, 0)

func _hand_bob(delta: float) -> void:
	if plr.is_moving:
		bob_time += delta * bob_speed
		
		var x_offset = sin(bob_time) * bob_amount
		var y_offset = cos(bob_time * 2.0) * bob_amount * 0.5
		
		position = rest_position + Vector2(x_offset, y_offset)
	else:
		bob_time = 0.0
		position = position.lerp(rest_position, 10.0 * delta)
