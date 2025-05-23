@tool class_name FatlasFormatLoader extends ResourceFormatLoader

const RECOGNIZED_EXTENSIONS : PackedStringArray = ["fat"]

func _handles_type(type: StringName) -> bool:
	return type == &"Resource"

func _get_recognized_extensions() -> PackedStringArray:
	return RECOGNIZED_EXTENSIONS

func _get_resource_script_class(path: String) -> String:
	return "Fatlas"

func _get_resource_type(path: String) -> String:
	return "Resource"

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var result := Fatlas.new()
		result.json_path = path

		if Engine.is_editor_hint():
			result.refresh_resources()

		return result
	else:
		printerr("Failed to load resource at path: ", path)
		return null