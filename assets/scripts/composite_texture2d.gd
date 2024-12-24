
@tool
class_name CompositeTexture2D extends Texture2D

static var unique_drawers : Dictionary
@export var components : Dictionary

const DEFAULT_KEY := "_r_a"

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	var canvas_item := CompositeTexture2D.get_unique_drawer(to_canvas_item)
	if canvas_item:
		if not components.has(canvas_item.texture_key): return
		components[canvas_item.texture_key].draw(to_canvas_item, pos, modulate, transpose)
	else:
		components[DEFAULT_KEY].draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	var canvas_item := CompositeTexture2D.get_unique_drawer(to_canvas_item)
	if canvas_item:
		if not components.has(canvas_item.texture_key): return
		components[canvas_item.texture_key].draw_rect(to_canvas_item, rect, tile, modulate, transpose)
	else:
		components[DEFAULT_KEY].draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	var canvas_item := CompositeTexture2D.get_unique_drawer(to_canvas_item)
	if canvas_item:
		if not components.has(canvas_item.texture_key): return
		components[canvas_item.texture_key].draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)
	else:
		components[DEFAULT_KEY].draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)


func _get_width() -> int:
	return components[DEFAULT_KEY].get_width()


func _get_height() -> int:
	return components[DEFAULT_KEY].get_height()


# func _is_pixel_opaque(x: int, y: int) -> bool:
# 	return components[DEFAULT_KEY].is_pixel_opaque(x, y)
# 	# return true


func _has_alpha() -> bool:
	return components[DEFAULT_KEY].has_alpha()


static func get_unique_drawer(rid: RID) -> CanvasItem:
	return unique_drawers.get(rid)
