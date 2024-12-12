
@tool
extends Node2D

var _custom_offset : Vector2
@export var custom_offset : Vector2 :
	get: return _custom_offset
	set(value):
		if _custom_offset == value: return
		_custom_offset = value
		update_offset()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.centered = false
	if self.has_signal("texture_changed"):
		self.texture_changed.connect(update_offset)
	update_offset()



func update_offset() -> void:
	self.offset = _custom_offset
	if self.texture is OffsetAtlasTexture:
		self.offset += Vector2(self.texture.offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

