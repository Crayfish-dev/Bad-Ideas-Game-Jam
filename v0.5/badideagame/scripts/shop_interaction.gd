extends Interactable
class_name Shop

@export var small_talks : Array[String] = [
	"Jaffar, you're back talking to walls aren't you?",
	"Im bored, you still doing the same lame job Jaffar?",
	"What about using your powers to do soemthing usefull?",
	"You still want boxes right? what about my maic powder?",
	"Anything new? Your mother was right, you're a total failiure",
	"Yo, these dead rats are tastier than expected, do you want some?",
	"Your hands are scary",
	"Wanna meet my cockroach? it's called Sir Manitrous The III",
	"Leave me alone!",
	"Can't you just use your hands? obiusly you're too special to do that"
]

func _process(delta: float) -> void:
	pass

func use(pl : Player):
	var text = small_talks.pick_random()
	pl.play_dialogue("???", [text])
	
