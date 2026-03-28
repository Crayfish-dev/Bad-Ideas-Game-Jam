extends Item
class_name RustyItem

@export var rusted_texture : Texture2D
@export var normal_texture : Texture2D
@export var rusted_name : String = "rusted item"
@export var normal_name : String = "normal item"
@export var rusted_des : String = "rusted description"
@export var normal_des : String = "normal description"
var material_instance : StandardMaterial3D = null

func _custom_ready():
	should_work = true
	sound_string = "res://assets/SFX/metal_hit_sound.mp3"
	var mat = $Model.mesh.surface_get_material(0)
	if mat != null:
		material_instance = mat.duplicate() as StandardMaterial3D
		$Model.mesh.surface_set_material(0, material_instance)

func _custom_process(delta : float):
	if material_instance == null:
		return

	if is_ready:
		_name = normal_name
		_description = normal_des
		material_instance.albedo_texture = normal_texture
	else:
		_name = rusted_name
		_description = rusted_des
		material_instance.albedo_texture = rusted_texture
