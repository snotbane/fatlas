
@tool
extends EditorPlugin

var PREVIEW_GENERATOR_SCRIPT := preload("res://addons/penny_atlas_godot/assets/scripts/composite_texture2d_preview_generator.gd")
var preview_generator : EditorResourcePreviewGenerator

func _enter_tree() -> void:
	preview_generator = PREVIEW_GENERATOR_SCRIPT.new()
	print(preview_generator)
	EditorInterface.get_resource_previewer().add_preview_generator(preview_generator)


func _exit_tree() -> void:
	EditorInterface.get_resource_previewer().remove_preview_generator(preview_generator)


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
