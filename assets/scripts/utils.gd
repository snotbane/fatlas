@tool class_name FatlasUtils

static func get_paths_in_folder(root := "res://", include := RegEx.create_from_string(".*")) -> PackedStringArray:
	var dir := DirAccess.open(root)
	if not dir: return []

	var result : PackedStringArray = []
	dir.list_dir_begin()
	var file : String = dir.get_next()
	while file:
		var next := root.path_join(file)
		if dir.current_is_dir():
			result.append_array(get_paths_in_folder(next, include))
		elif include.search(file):
			result.push_back(next)
		file = dir.get_next()
	return result

# static func load_resources_in_folder(root := "res://", include := RegEx.create_from_string(".*")) -> Array:
# 	var result : Array = []
# 	for i in get_paths_in_folder(root, include):
# 		result.push_back(load(i))
# 	return result
