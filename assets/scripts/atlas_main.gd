
@tool
extends Node

class MegaImageClip:
	var mega : MegaImage
	var name : String
	var folder_name : String
	var image : Image
	var region : Rect2i
	var offset : Vector2i

	var path : String :
		get: return folder_name + name + ".tres"

	func _init(_mega: MegaImage, texture : Texture2D) -> void:
		mega = _mega
		folder_name = texture.resource_path.substr(0, texture.resource_path.rfind("/") + 1)
		name = texture.resource_path.substr(folder_name.length())
		name = name.substr(0, name.rfind("."))
		image = texture.get_image()
		region = image.get_used_rect()
		offset = image.get_used_rect().position

		if image.get_format() != mega.image.get_format():
			image.convert(mega.image.get_format())


	func create_atlas(texture: Texture2D) -> OffsetAtlasTexture:
		var result := OffsetAtlasTexture.new()
		result.offset = offset
		result.atlas = texture
		result.region = region
		return result


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

	var clips : Array[MegaImageClip]

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


	func add(texture: Texture2D) -> void:
		var clip := MegaImageClip.new(self, texture)

		var used := clip.image.get_used_rect()
		var rect := Rect2i(get_snap_for(used.size), used.size)

		if not full_rect.encloses(rect):
			size = full_rect.merge(rect).size

		image.blit_rect(clip.image, used, rect.position)
		clip.region.position = rect.position
		add_clip(clip)


	func add_clip(clip: MegaImageClip) -> void:
		clips.push_back(clip)
		snaps.erase(clip.region.position)
		var snap1 := clip.region.position + Vector2i.RIGHT * clip.region.size.x
		if not snaps.has(snap1):
			snaps.push_back(snap1)
		var snap2 := clip.region.position + Vector2i.DOWN * clip.region.size.y
		if not snaps.has(snap2):
			snaps.push_back(snap2)


	func get_snap_for(query_size: Vector2i) -> Vector2i:
		var candidates : Array[Rect2i] = []
		for snap in snaps:
			var query := Rect2i(snap, query_size)
			var intersects := false
			for clip in clips:
				if clip.region.intersects(query):
					intersects = true
					break
			if not intersects:
				candidates.push_back(query)

		if candidates.is_empty():
			print(snaps)
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
		i += 1
		mega_image.add(texture)

	if not mega_image.image.save_png(target_path) == OK: return

	var res := load(target_path)
	for clip in mega_image.clips:
		var atlas := clip.create_atlas(res)
		var path := target_folder + clip.name + ".tres"
		ResourceSaver.save(atlas, path)

	print("Finished")

	EditorInterface.get_resource_filesystem().scan.call_deferred()


static func get_images(start: String) -> Array[Texture2D]:
	var result : Array[Texture2D] = []

	for path in Utils.get_paths_in_project(".png", Utils.OMIT_FILE_SEARCH_DEFAULT, start + "/"):
		var resource : Resource = load(path)
		if resource is CompressedTexture2D:
			result.push_back(resource)

	return result
