
@tool
class_name AtlasMapper extends Resource

const NAME_PATTERN : String = ".*?(?=_._.)"
const TEMPLATE_PATTERN : String = "_r_a$"
const INDEX_PATTERN : String = "(.*?_)(\\d+)$"
const REQUIRED_PATTERNS : PackedStringArray = [
	"_r(?=_.$)",
	"_l(?=_.$)",
]
const OPTIONAL_PATTERNS : PackedStringArray = [
	# "_a",
	# "_e",
	# "_m",
	"_n",
	# "_o",
]
const NON_TEMPLATE_PATTERNS : PackedStringArray = [
	"_r_e$",
	"_r_m$",
	"_r_n$",
	"_r_o$",
	"_l_a$",
	"_l_e$",
	"_l_m$",
	"_l_n$",
	"_l_o$",
]

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
@export_dir var export_folder : String
@export_dir var other_folder : String
@export_storage var created_paths : PackedStringArray


func do_destroy(scan: bool = true) -> void:
	for path in created_paths:
		if not FileAccess.file_exists(path): continue
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		if scan:
			EditorInterface.get_resource_filesystem().scan()
	created_paths.clear()


func do_reimport() -> void:
	do_destroy(false)

	var file := FileAccess.open(data_file_path, FileAccess.READ)
	var data : Dictionary = JSON.parse_string(file.get_as_text())
	var alt_versions : Array[OffsetAtlasTexture] = []
	var templates : Dictionary
	# var name_regex := RegEx.create_from_string(NAME_PATTERN)
	var template_regex := RegEx.create_from_string(TEMPLATE_PATTERN)
	var index_regex := RegEx.create_from_string(INDEX_PATTERN)

	for k in data.keys():
		var mega_texture_path : String = data_file_path.substr(0, data_file_path.rfind("/") + 1) + k
		var mega_texture : Texture2D = load(mega_texture_path)
		for entry in data[k]:
			# var generic_name := name_regex.search(entry["name"]).get_string()
			var template_match := template_regex.search(entry["name"])
			
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

			var atlas : OffsetAtlasTexture
			var atlas_path : String = "%s/%s.tres"
			if template_match:
				atlas = OffsetAtlasTextureTemplate.new()
				atlas.name = entry["name"].substr(0, template_match.get_start())
				atlas_path %= [export_folder, atlas.name]
				templates[atlas.name] = atlas_path
			else:
				atlas = OffsetAtlasTexture.new()
				atlas.name = entry["name"]
				atlas_path %= [other_folder, entry["name"]]
				alt_versions.push_back(atlas)

			atlas.atlas = mega_texture
			atlas.offset = Vector2i(source_offset)
			atlas.region = Rect2(target_region)
			atlas.filter_clip = true

			var index_match := index_regex.search(atlas.name)
			if index_match:
				var index := int(index_match.get_string(2))
				if index > 0:
					var index_string := "0".pad_zeros(index_match.get_string(2).length())
					atlas.index_zero_name = index_match.get_string(1) + index_string + index_match.get_string(3)
					print("Found indexed: %s -> %s" % [atlas.name, atlas.index_zero_name])

			ResourceSaver.save(atlas, atlas_path)
			created_paths.push_back(atlas_path)
			# print("Created atlas '%s'" % atlas.name)

	# print("Names: ", alt_versions.map(func(i): return i.name))
	# for i in alt_versions:
	# 	print(i.name)
			
	for k in templates.keys():
		# var template : OffsetAtlasTextureTemplate = load(templates[k])
		var template : OffsetAtlasTextureTemplate = ResourceLoader.load(templates[k], "", ResourceLoader.CacheMode.CACHE_MODE_IGNORE_DEEP)
		template.maps.clear()

		for optional in OPTIONAL_PATTERNS:
			var r_suffix := "_r" + optional
			var r_name := template.name + r_suffix

			# var l_suffix := "_l" + optional
			# var l_name := template.name + l_suffix

			print("Looking for R: ", r_name)

			var i := 0
			for alt in alt_versions:
				if i == 2: break
				if alt.name == r_name:
					template.maps[r_suffix] = alt
					print("Found R: ", r_name, ": ", alt)
					i += 1
				# elif alt.name == l_name:
				# 	template.maps[l_suffix] = alt
				# 	print("Found L: ", l_name, ": ", alt)
					i += 1

			# prints(template.name,  r_suffix)
			# if not template.maps.has(r_suffix) and template.index_zero_name and templates[template.index_zero_name][0].maps.has(r_suffix):
			# 	template.maps[r_suffix] = templates[template.index_zero_name][0].maps[r_suffix]

			# if not template.maps.has(l_suffix) and template.maps.has(r_suffix):
			# 	template.maps[l_suffix] = template.maps[r_suffix]

		# print("connected template: ", template.name)
		# print("maps: ", template.maps.keys())
		ResourceSaver.save(template, templates[k][1])

	EditorInterface.get_resource_filesystem().scan()
