extends Control

@export var pl : Player
@export var price : int = 10
@export var _name : String = "small box"
@export var scene : PackedScene
@export var texture : CompressedTexture2D

@onready var sprite: TextureRect = $Sprite
@onready var name_label: Label = $Name
@onready var buy: TextureButton = $Buy

func _process(delta: float) -> void:
	name_label.text = "name: " + _name + " price: " + str(price) + "$"
	sprite.texture = texture
	if GameManager.money >= price:
		buy.disabled = false
	else:
		buy.disabled = true

func _on_buy_pressed() -> void:
	var item = scene.instantiate()
	pl.item_spawning_point.add_child(item)
	item.global_position = pl.item_spawning_point.global_position
	GameManager.money -= price
