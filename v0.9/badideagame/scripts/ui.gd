extends Control

@onready var dark: TextureRect = $Dark
@onready var name_label: Label = $BuyBackground/NameLabel
@onready var cost_label: Label = $BuyBackground/CostLabel
@onready var eye: Sprite2D = $Crack/Eye
@onready var hand: TextureRect = $"../CursorSprite/Hand"

func _process(delta: float) -> void:
	eye.look_at(get_global_mouse_position())
	hand.visible = not visible
