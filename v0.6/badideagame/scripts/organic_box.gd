extends Box
class_name OrganicBox

@export var min_size: float = 0.5
@export var max_size: float = 5.0
@export var size_deterior_rate: float = 0.5
@export var tween_duration: float = 0.25

var _tween: Tween

var size: float:
	get:
		return _size
	set(value):
		_size = clamp(value, min_size, max_size)

		if _tween:
			_tween.kill()

		_tween = create_tween()
		_tween.tween_property(self, "scale", Vector3(_size, _size, _size), tween_duration)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		scale = Vector3(_size,_size,_size)
		print(scale)

func _custom_ready() -> void:
	_size = max_size
	scale = Vector3(_size,_size,_size)
	print(scale)

func deteriorate() -> void:
	size -= size_deterior_rate
