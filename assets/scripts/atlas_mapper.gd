
@tool
class_name AtlasMapper extends Resource

@export var create_resources : bool :
	set(value):
		do_reimport()

@export var destroy_resources : bool :
	set(value):
		if created_paths.is_empty():
			printerr("No resources to destroy.")
			return

		var confirm := ConfirmationDialog.new()
		confirm.dialog_text = "This will remove all Resource assets from the project that this mapper has created. You wanna?"

		confirm.confirmed.connect(confirm.queue_free)
		confirm.confirmed.connect(do_destroy)
		confirm.canceled.connect(confirm.queue_free)

		EditorInterface.get_base_control().add_child(confirm)
		confirm.popup_centered()
		await Async.any([confirm.confirmed, confirm.canceled])

		confirm.queue_free()


@export var images : Array[Texture2D]
@export_file("*.json") var data_file_path : String
@export_dir var maps_folder : String
@export_dir var composites_folder : String
@export_storage var created_paths : Dictionary


func do_destroy(scan: bool = true) -> void:
	for k in created_paths:
		var path : String = created_paths[k]
		if not FileAccess.file_exists(path): continue
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		if scan:
			EditorInterface.get_resource_filesystem().scan()
	created_paths.clear()


func do_reimport() -> void:
	do_destroy(false)

	var file := FileAccess.open(data_file_path, FileAccess.READ)
	var data : Dictionary = JSON.parse_string(file.get_as_text())

	var maps : Dictionary = data["maps"]
	for k in maps.keys():
		var mega_texture_path : String = data_file_path.substr(0, data_file_path.rfind("/") + 1) + k
		var mega_texture : Texture2D = load(mega_texture_path)
		for entry in maps[k]:			
			var source_offset := Vector2i(
				entry["source_offset"]["x"],
				entry["source_offset"]["y"],
			)
			var target_region := Rect2i(
				entry["target_region"]["x"],
				entry["target_region"]["y"],
				entry["target_region"]["w"],
				entry["target_region"]["h"],
			)

			var atlas := OffsetAtlasTexture.new()
			atlas.name = entry["name"]
			atlas.atlas = mega_texture
			atlas.offset = Vector2i(source_offset)
			atlas.region = Rect2(target_region)
			atlas.filter_clip = true

			var atlas_path : String = "%s/%s.tres" % [maps_folder, atlas.name]
			ResourceSaver.save(atlas, atlas_path)
			created_paths[atlas.name] = atlas_path

	var composites : Dictionary = data["composites"]
	for base_name in composites.keys():
		var base : Dictionary = composites[base_name]
		var composite := CompositeTexture2D.new()
		var composite_path : String = "%s/%s.tres" % [composites_folder, base_name]
		for suffix in base.keys():
			var link : String = base[suffix]
			composite.maps[suffix] = load(created_paths[link])
		ResourceSaver.save(composite, composite_path)
		# EditorInterface.get_resource_previewer().queue_edited_resource_preview(composite, composite, "bar", null)
		# EditorInterface.get_resource_previewer().queue_resource_preview(composite_path, composite, "bar", null)
		# EditorInterface.get_resource_previewer().queue_resource_preview(composite_path, composite, "bar", null)

	EditorInterface.get_resource_filesystem().scan()


func foo() -> void:
	pass