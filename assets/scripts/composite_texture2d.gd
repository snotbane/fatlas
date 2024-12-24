
@tool
class_name CompositeTexture2D extends Texture2D

static var unique_drawers : Dictionary
@export var maps : Dictionary

const DEFAULT_KEY := "_r_a"

var default_map : Texture2D :
	get: return maps[DEFAULT_KEY]

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	var canvas_item := CompositeTexture2D.get_unique_drawer(to_canvas_item)
	if canvas_item:
		if not maps.has(canvas_item.texture_key): return
		draw_proxy(maps[canvas_item.texture_key], to_canvas_item, pos, modulate, transpose)
	else:
		draw_proxy(default_map, to_canvas_item, pos, modulate, transpose)
func draw_proxy(texture: Texture2D, to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	texture.draw(to_canvas_item, pos, modulate, transpose)


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	var canvas_item := CompositeTexture2D.get_unique_drawer(to_canvas_item)
	if canvas_item:
		if not maps.has(canvas_item.texture_key): return
		draw_rect_proxy(maps[canvas_item.texture_key], to_canvas_item, rect, tile, modulate, transpose)
	else:
		draw_rect_proxy(default_map, to_canvas_item, rect, tile, modulate, transpose)
func draw_rect_proxy(texture: Texture2D, to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	var canvas_item := CompositeTexture2D.get_unique_drawer(to_canvas_item)
	if canvas_item:
		if not maps.has(canvas_item.texture_key): return
		draw_rect_region_proxy(maps[canvas_item.texture_key], to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)
	else:
		draw_rect_region_proxy(default_map, to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)
func draw_rect_region_proxy(texture: Texture2D, to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if texture is OffsetAtlasTexture:
		rect.position += Vector2(texture.offset - default_map.offset)
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)




func _get_width() -> int:
	return maps[DEFAULT_KEY].get_width()


func _get_height() -> int:
	return maps[DEFAULT_KEY].get_height()


# func _is_pixel_opaque(x: int, y: int) -> bool:
# 	return maps[DEFAULT_KEY].is_pixel_opaque(x, y)
# 	# return true


func _has_alpha() -> bool:
	return maps[DEFAULT_KEY].has_alpha()


func bar(path: String, preview: Texture2D, thumbnail_preview: Texture2D, userdata: Variant) -> Variant:
	print("Bar!!!")
	return userdata


static func get_unique_drawer(rid: RID) -> CanvasItem:
	return unique_drawers.get(rid)
