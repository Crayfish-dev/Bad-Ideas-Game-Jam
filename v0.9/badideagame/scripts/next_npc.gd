extends Interactable
class_name ServiceBell

const MAX_PRESS_TIMER : float = 1.0
const PRESS_OFFSET : float = 0.02
var press_timer : float = 0.0
var _base_y : float
var _pressed : bool = false

func _ready() -> void:
	_base_y = position.y

func _process(delta: float) -> void:
	if press_timer > 0:
		press_timer -= delta
		_description = "waiting..."
		if press_timer <= 0 and _pressed:
			_pressed = false
			var tween = create_tween()
			tween.tween_property(self, "position:y", _base_y, 0.15)
	else:
		_description = "[E] click to skip client"

func _press() -> void:
	if _pressed:
		return
	press_timer = MAX_PRESS_TIMER
	_pressed = true
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "position:y", _base_y - PRESS_OFFSET, 0.5)
	if GameManager.current_NPC != null:
		GameManager.current_NPC.start_leaving()
	$Jingle.play()
