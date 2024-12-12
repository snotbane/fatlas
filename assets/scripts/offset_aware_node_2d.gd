
@tool
extends Node2D

var _custom_offset : Vector2
@export var custom_offset : Vector2 :
	get: return _custom_offset
	set(value):
		if _custom_offset == value: return
		_custom_offset = value
		update_offset_method.call()

var update_offset_method : Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.centered = false
	if self.has_signal("texture_changed"):
		update_offset_method = update_offset_sprite_2d
		self.texture_changed.connect(update_offset_method)
	elif self.has_signal("frame_changed"):
		update_offset_method = update_offset_animated_sprite_2d
		self.sprite_frames_changed.connect(update_offset_method)
		self.animation_changed.connect(update_offset_method)
		self.frame_changed.connect(update_offset_method)

	if update_offset_method != null:
		update_offset_method.call()


func update_offset_sprite_2d() -> void:
	self.offset = _custom_offset + Vector2(self.texture.offset)


func update_offset_animated_sprite_2d() -> void:
	self.offset = _custom_offset + Vector2(self.sprite_frames.get_frame_texture(self.animation, self.frame).offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

