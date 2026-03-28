extends Interactable
class_name Shop

@export var small_talks : Array[String] = [
	"Jaffar, you're back talking to walls aren't you?",
	"Im bored, you still doing the same lame job Jaffar?",
	"What about using your powers to do something usefull?",
	"You still want boxes right? what about my maic powder?",
	"Anything new? Your mother was right, you're a total failiure",
	"Yo, these dead rats are tastier than expected, do you want some?",
	"Your hands are scary",
	"Wanna meet my cockroach? it's called Sir Manitrous The III",
	"Leave me alone!",
	"Can't you just use your hands? obiusly you're too special to do that",
	"Is it just me or the messenger is kinda annoying, he gives too many items",
	"Do you think the farmer i really talking about tools when he says 'hoe'?",
	"Don't ask why i'm here, anyway do you want something or?",
	"Why do people even come here? can't they just do all this stuff without a wizard?",
	"Why do people even come here? can't they just do all this stuff without a wizard?",
	"Is it just me or everything is made of sticks and leather here?",
	"The priest thinks im a demon and i gave you powers, i didn't but i have better stuff here",
	"The priest thinks im a demon and i gave you powers, i didn't but i have better stuff here",
	"The priest thinks im a demon and i gave you powers, i didn't but i have better stuff here",
	"The priest thinks im a demon and i gave you powers, i didn't but i have better stuff here"
]

func _ready() -> void:
	randomize()

func use(pl : Player):
	var text = small_talks.pick_random()
	pl.play_dialogue("???", [text])
	pl.ui_open = true
	pl.shop_ui.visible = true
