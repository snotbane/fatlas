
@tool
class_name AtlasMapper extends Resource

@export_file("*.json") var json_path : String
# @export var images : Array[Texture2D]

@export_tool_button("Refresh Resources") var create_resources := do_reimport
# @export var destroy_resources : bool :
# 	set(value):
# 		if created_paths.is_empty():
# 			printerr("No resources to destroy.")
# 			return

# 		var confirm := ConfirmationDialog.new()
# 		confirm.dialog_text = "This will remove all Resource assets from the project that this mapper has created. You wanna?"

# 		confirm.confirmed.connect(confirm.queue_free)
# 		confirm.confirmed.connect(do_destroy)
# 		confirm.canceled.connect(confirm.queue_free)

# 		EditorInterface.get_base_control().add_child(confirm)
# 		confirm.popup_centered()
# 		await Async.any([confirm.confirmed, confirm.canceled])

# 		confirm.queue_free()


var self_folder : String :
	get: return self.resource_path.substr(0, self.resource_path.rfind("/"))

var atlases_folder : String :
	get: return self_folder.path_join("atlases")
var composites_folder : String :
	get: return self_folder.path_join("composites")
var textures_folder : String :
	get: return self_folder.path_join("textures")


# func do_destroy(scan: bool = true) -> void:
# 	for k in created_paths:
# 		var path : String = created_paths[k]
# 		if not FileAccess.file_exists(path): continue
# 		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
# 		if scan:
# 			EditorInterface.get_resource_filesystem().scan()
# 	created_paths.clear()


func do_reimport() -> void:
	if not DirAccess.dir_exists_absolute(textures_folder):
		printerr("textures folder does not exist.")
		return
	if not DirAccess.dir_exists_absolute(atlases_folder):
		DirAccess.make_dir_recursive_absolute(atlases_folder)
	if not DirAccess.dir_exists_absolute(composites_folder):
		DirAccess.make_dir_recursive_absolute(composites_folder)

	var images : Array[Texture2D]
	for i in Utils.get_paths_in_project(".png", [], textures_folder):
		images.push_back(load(i))

	# do_destroy(false)
	var created_paths : Dictionary

	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		printerr("AtlasMapper: null file at path '%s'" % json_path)
		return

	var data : Dictionary = JSON.parse_string(file.get_as_text())

	var texture : Dictionary = data["atlas"]
	for k in texture.keys():
		var mega_texture_path : String = json_path.substr(0, json_path.rfind("/") + 1).path_join(k)
		var mega_texture : Texture2D = load(mega_texture_path)
		for subimage_name in texture[k].keys():
			var coord : Array = texture[k][subimage_name]
			var source_offset := Vector2i(coord[2], coord[3])
			var target_region := Rect2i(coord[0], coord[1], coord[4], coord[5])

			var atlas_path : String = atlases_folder.path_join(subimage_name + ".tres")
			var atlas : OffsetAtlasTexture
			if FileAccess.file_exists(atlas_path):
				atlas = load(atlas_path)
			else:
				atlas = OffsetAtlasTexture.new()

			atlas.name = subimage_name
			atlas.atlas = mega_texture
			atlas.offset = Vector2i(source_offset)
			atlas.region = Rect2(target_region)
			atlas.filter_clip = true

			ResourceSaver.save(atlas, atlas_path)
			created_paths[atlas.name] = atlas_path

	var compo : Dictionary = data["compo"]
	for base_name in compo.keys():
		var base : Dictionary = compo[base_name]

		var composite_path : String = composites_folder.path_join(base_name + ".tres")
		var composite : CompositeTexture2D
		if FileAccess.file_exists(composite_path):
			composite = load(composite_path)
			composite.maps.clear()
		else:
			composite = CompositeTexture2D.new()

		for suffix in base.keys():
			var link : String = base[suffix]
			composite.maps[suffix] = load(created_paths[link])

		ResourceSaver.save(composite, composite_path)

		# EditorInterface.get_resource_previewer().queue_edited_resource_preview(composite, composite, "bar", null)
		# EditorInterface.get_resource_previewer().queue_resource_preview(composite_path, composite, "bar", null)
		# EditorInterface.get_resource_previewer().queue_resource_preview(composite_path, composite, "bar", null)

	EditorInterface.get_resource_filesystem().scan()
