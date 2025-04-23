@tool extends EditorPlugin

var PREVIEW_GENERATOR_SCRIPT := preload("res://addons/penny_atlas_godot/assets/scripts/composite_texture2d_preview_generator.gd")
var preview_generator : EditorResourcePreviewGenerator

func _enable_plugin() -> void:
	preview_generator = PREVIEW_GENERATOR_SCRIPT.new()
	# print(preview_generator)
	EditorInterface.get_resource_previewer().add_preview_generator(preview_generator)
	EditorInterface.get_resource_filesystem().resources_reimported.connect(_on_resources_reimported)


func _disable_plugin() -> void:
	EditorInterface.get_resource_previewer().remove_preview_generator(preview_generator)
	EditorInterface.get_resource_filesystem().resources_reimported.disconnect(_on_resources_reimported)


func _has_main_screen() -> bool:
	# return true
	return false


func _make_visible(visible: bool) -> void:
	# if main_panel:
	# 	main_panel.visible = visible
	pass


func _get_plugin_name() -> String:
	return "Atlas"


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("AtlasTexture", "EditorIcons")


func _on_resources_reimported(resources: PackedStringArray) -> void:
	for path in resources:
		if path.ends_with(".fat"):
			_on_fatlas_resource_reimported(path)

func _on_fatlas_resource_reimported(path: String) -> void:
	ResourceLoader.load(path, "", ResourceLoader.CacheMode.CACHE_MODE_IGNORE)

