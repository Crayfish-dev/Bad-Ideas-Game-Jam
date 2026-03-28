extends RigidBody3D
class_name Item
@export var _name : String = "item"
@export var _description : String = "item description"
@export var grab_force : float = 30.0
@export var grab_damping : float = 0.9
@export var impact_threshold : float = 0.5
@export var sound_string : String = "res://assets/SFX/hit_sound.mp3"
@export_group("Interacitons")
@export var should_work : bool = false
@onready var outline: AnimationPlayer = $Outline
@onready var impact_audio: AudioStreamPlayer3D = $HitSound
var is_ready : bool = false
var grabbed : bool = false
var can_be_grabbed : bool = true
var grabbing_pos : Vector3 = Vector3.ZERO

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	
	_custom_ready()
	is_ready = not should_work
	scale = Vector3.ZERO
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector3.ONE, 0.5)
	await get_tree().create_timer(0.2).timeout
	$PopSound.stream.random_pitch = 0.2
	$PopSound.play()

func _on_body_entered(body: Node):
	var impact_velocity = linear_velocity.length()
	if impact_velocity >= impact_threshold:
		_play_impact_sound(impact_velocity)

func _play_impact_sound(velocity: float):
	impact_audio.stream = load(sound_string)
	impact_audio.volume_db = lerp(-30.0, 40.0, clamp(velocity / 10.0, 0.0, 1.0))
	impact_audio.pitch_scale = randf_range(0.5, 1.0)
	impact_audio.play()

func _custom_ready():
	pass
func _custom_process(delta : float):
	pass

func _physics_process(delta: float) -> void:
	if grabbed and can_be_grabbed:
		var offset = grabbing_pos - global_position
		var distance = offset.length()
		if distance > 0.01:
			var force = offset.normalized() * distance * grab_force
			apply_central_force(force)
		linear_velocity *= grab_damping

func _process(delta: float) -> void:
	_custom_process(delta)

func _reset_center():
	center_of_mass = Vector3.ZERO
