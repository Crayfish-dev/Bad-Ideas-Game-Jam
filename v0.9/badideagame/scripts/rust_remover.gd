extends Interactable
class_name RustRemover

var bodies_inside: Array[RustyItem] = []

@export var process_time: int = 1800
var process_tmr: int = 0
var opened: bool = false

@onready var hour_glass_pivot: Node3D = $HourGlassPivot

func _process(delta: float) -> void:
	if process_tmr > 0:
		process_tmr -= 1

		var progress = 1.0 - float(process_tmr) / float(process_time)
		hour_glass_pivot.rotation_degrees.x = progress * 360.0

		if process_tmr <= 0:
			process_tmr = 0
			if bodies_inside.size() > 0:
				for body in bodies_inside:
					if is_instance_valid(body):
						body.is_ready = true

	if seen:
		seen = false


func open_close(rot: float, open: bool) -> void:
	opened = open
	$LidShape.disabled = opened

	var target_rot := 0.0
	if open:
		target_rot = -rot

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)

	if open:
		tween.set_trans(Tween.TRANS_ELASTIC)
	else:
		tween.set_trans(Tween.TRANS_SINE)

	tween.tween_property($Lid, "rotation_degrees:z", target_rot, 0.5)

func _on_inside_area_body_entered(body: RustyItem) -> void:
	if body not in bodies_inside:
		bodies_inside.append(body)
		print("started")
		process_tmr = process_time

func _on_inside_area_body_exited(body: RustyItem) -> void:
	if body in bodies_inside:
		bodies_inside.erase(body)
