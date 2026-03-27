extends Interactable
class_name BookOfKnoledge

@export var pl : Player

@export var dialogue_pages : Array[String] = [
	"Good morning Jaffar, it's me, the old book of knowledge...",
	"I have been given the noble task of instructing you...",
	"First of all, do you know how to use your telekinetic powers?...",
	"Probably not, so remember: look at an object and hold down LEFT MOUSE BUTTON...",
	"While holding an object, you can interact with it or move it closer/further away with the ARROW KEYS",
	"Now you're kinda broke, but you'll get money later...",
	"If you need anything, try talking to the random crack on the wall (Please don't) on your right...",
	"Remember to serve clients, interact with them and they'll give you tasks...",
	"Your job is to basically organize the things they give you...",
	"Try to use as few boxes as possible, otherwise you will be paid less...",
	"If you run out of them, just buy more! (Welcome to the Black Market BABYYY)",
	"You may also encounter rusty items that need some love before being delivered",
	"Just put them inside the Rust Remover and wait for them to shine!",
	"That was kinda cringe ngl...",
	"...",
	"Sh*t, im getting side-tracked... what was i saying?...",
	"Oh right, im not paid enough to continue, BYE (My memory will be erased)",
	"yufnws...AunifgYDUEINRHYC7...U42XFMGR3F7F3GSKcndgxwq....uCGRNYXUEMQGGIWQQQdemzg"
]

@export var book_name : String = "The Old Book of Divinge Knowledge"

var current_page : int = 0
var is_reading : bool = false


func _process(delta: float) -> void:
	if pl == null:
		return
	var target_pos = pl.global_position
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)


func interact(player: Player) -> void:
	if is_reading or dialogue_pages.is_empty():
		return
	
	is_reading = true
	
	var line = dialogue_pages[current_page]
	current_page = (current_page + 1) % dialogue_pages.size()
	
	await player.play_dialogue(book_name, [line])
	
	is_reading = false
