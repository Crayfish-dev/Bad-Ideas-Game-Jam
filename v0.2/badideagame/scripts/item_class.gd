extends RigidBody3D
class_name Item

@export var _name : String = "item" # name
@export var _description : String = "item description"
@export var grab_force : float = 30.0
@export var grab_damping : float = 0.9
@export var crf : float = 0.5 # "central randomized factor"

@onready var outline: AnimationPlayer = $Outline

var grabbed : bool = false
var grabbing_pos : Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if grabbed:
		var offset = grabbing_pos - global_position # found this formula randomly on the internet btw
		var distance = offset.length()
		
		if distance > 0.01:
			var force = offset.normalized() * distance * grab_force
			apply_central_force(force)
		
		linear_velocity *= grab_damping

func _randomize_center():
	var pos = Vector3(randf_range(-crf, crf), randf_range(-crf, crf), randf_range(-crf, crf))
	center_of_mass += pos

func _reset_center():
	center_of_mass = Vector3.ZERO
