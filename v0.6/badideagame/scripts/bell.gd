extends Area3D

@onready var model_pivot: Node3D = $ModelPivot
@onready var jingle: AudioStreamPlayer3D = $Jingle

const BELL_DURATION := 0.89
const BELL_SWINGS := 6
const BELL_ANGLE := 18.0

func _on_body_entered(body: NPC) -> void:
	ring_bell()

func ring_bell() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	jingle.play()
	var step_time := BELL_DURATION / (BELL_SWINGS * 2)
	var angle := BELL_ANGLE

	for i in range(BELL_SWINGS):
		var direction := 1.0 if i % 2 == 0 else -1.0
		var rad := deg_to_rad(angle * direction)
		tween.tween_property(model_pivot, "rotation:z", rad, step_time)
		tween.tween_property(model_pivot, "rotation:z", -rad, step_time)
		angle *= 0.65

	tween.tween_property(model_pivot, "rotation:z", 0.0, step_time * 1.5)
