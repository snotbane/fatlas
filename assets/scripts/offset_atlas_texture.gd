
@tool
class_name OffsetAtlasTexture extends AtlasTexture

@export var offset : Vector2i

func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	draw(to_canvas_item, Vector2.ZERO, Color.BLACK, transpose)
	print("Hi")


func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	draw_rect(to_canvas_item, Rect2(), false, Color.BLACK, transpose)
	print("Hi")


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	draw_rect_region(to_canvas_item, Rect2(), Rect2(), Color.BLACK, transpose, false)
	print("Hi")


	# self._draw(to_canvas_item, pos, modulate, transpose)
	# draw_circle(Vector2.ZERO, 10, Color.WHITE)
	# self.draw(to_canvas_item, pos + Vector2.ONE * 50, modulate, transpose)
