
@tool
class_name CompositeSprite2D extends Sprite2D

const COMPONENT_KEYS = ["a", "n", "o", "e", "m"]

var _composite : CompositeTexture2D
var composite : CompositeTexture2D :
	get: return _composite
	set(value):
		if _composite == value: return
		if _composite:
			CompositeTexture2D.unique_drawers.erase(self.get_canvas_item())
		_composite = value
		if _composite:
			CompositeTexture2D.unique_drawers[self.get_canvas_item()] = self
		queue_redraw()

var _mirrored : bool
@export var mirrored : bool :
	get: return _mirrored
	set(value):
		if _mirrored == value: return
		_mirrored = value
		queue_redraw()

var _component : int
@export_range(0, 4) var component : int :
	get: return _component
	set(value):
		if _component == value: return
		_component = value
		queue_redraw()


var texture_key : String :
	get:
		var mirrored_string : String = "l" if _mirrored else "r"
		var component_string : String = COMPONENT_KEYS[_component]
		return "_%s_%s" % [mirrored_string, component_string]


func _enter_tree() -> void:
	self.texture_changed.connect(refresh_from_texture)


func refresh_from_texture() -> void:
	if self.texture is CompositeTexture2D:
		composite = self.texture
	else:
		composite = null


func refresh_from_attributes() -> void:
	pass