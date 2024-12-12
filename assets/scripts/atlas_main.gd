
@tool
extends Node

class MegaImage :
	var image : Image
	var bitmap : BitMap :
		get:
			var result : BitMap = BitMap.new()
			result.resize(image.get_size())
			for rect in rects_cumulative:
				result.set_bit_rect(rect, true)
			return result

	var rects : Array[Rect2i]
	var rects_cumulative : Array[Rect2i]
	var snaps : Array[Vector2i] = [ Vector2i.ZERO ]

	var _width : int = 1
	var _hight : int = 1
	var size : Vector2i :
		get: return Vector2i(_width, _hight)
		set(value):
			if size == value: return
			_width = value.x
			_hight = value.y
			image.crop(_width, _hight)
			print("Resized to ", image.get_size())

	var full_rect : Rect2i :
		get: return Rect2i(Vector2i.ZERO, size)


	func _init(format: int = Image.FORMAT_RGBA8) -> void:
		image = Image.create_empty(1, 1, false, format)


	func add(clip: Image) -> void:
		clip.convert(Image.FORMAT_RGBA8)

		var rect := Rect2i(get_snap_for(clip), clip.get_size())

		if not full_rect.encloses(rect):
			size = full_rect.merge(rect).size
		print("Placing new image at ", rect.position)

		image.blit_rect(clip, Rect2i(Vector2i.ZERO, rect.size), rect.position)
		add_rect(rect)


	func add_rect(rect: Rect2i) -> void:
		rects.push_back(rect)
		rects_cumulative.push_back(rect)
		snaps.erase(rect.position)
		var snap1 := rect.position + Vector2i.RIGHT * rect.size.x
		var snap2 := rect.position + Vector2i.DOWN * rect.size.y
		if not snaps.has(snap1):
			snaps.push_back(snap1)
		if not snaps.has(snap2):
			snaps.push_back(snap2)


	func get_snap_for(clip: Image):
		var candidates : Array[Rect2i] = []
		for snap in snaps:
			var query := Rect2i(snap, clip.get_size())
			for rect in rects:
				if rect.intersects(query): continue
				candidates.push_back(query)
				break
		if candidates.is_empty():
			return snaps[0]
		candidates.sort_custom(sort_candidates)
		return candidates[0].position


	func sort_candidates(a: Rect2i, b: Rect2i) -> bool:
		return full_rect.encloses(a) and not full_rect.encloses(b)




@export var source_button : Button
@export var target_button : Button

var source_path : String
var target_path : String

var target_folder : String :
	get: return target_path.substr(0, target_path.rfind("/") + 1)

func _ready() -> void:
	$source_dialog.dir_selected.connect(on_source_chosen)
	$target_dialog.file_selected.connect(on_target_chosen)


func on_source_chosen(path: String) -> void:
	source_path = path
	source_button.text = source_path


func on_target_chosen(path: String) -> void:
	target_path = path
	target_button.text = target_path


func go() :
	if target_path.is_empty():
		printerr("Can't atlas to an empty target.")
		return

	print("Start")

	var i = 0
	var limit = 16

	var mega_image := MegaImage.new()

	for texture in get_images(source_path):
		if i >= limit: break

		# var res_name : String = texture.resource_path.substr(texture.resource_path.rfind("/") + 1)
		mega_image.add(texture.get_image())

		i += 1

	for j in 0:
		# res_name = res_name.substr(0, res_name.rfind("."))
		# var atlas_path : String = target_folder + res_name + ".tres"

		# var atlas := AtlasTexture.new()
		# atlas.atlas = res

		# print(atlas_path)
		# ResourceSaver.save(atlas, atlas_path)
		break

	mega_image.image.save_png(target_path)
	mega_image.bitmap.convert_to_image().save_png(target_path.substr(0, target_path.length() - 4) + "_bitmap.png")

	print("Finished")

	EditorInterface.get_resource_filesystem().scan()
	# EditorInterface.get_resource_filesystem().reimport_files([target_path])


static func get_images(start: String) -> Array[Texture2D]:
	var result : Array[Texture2D] = []

	for path in Utils.get_paths_in_project(".png", Utils.OMIT_FILE_SEARCH_DEFAULT, start + "/"):
		var resource : Resource = load(path)
		if resource is CompressedTexture2D:
			result.push_back(resource)

	return result
