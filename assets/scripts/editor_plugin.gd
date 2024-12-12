@tool
extends EditorPlugin

const MAIN_PANEL_SCENE : PackedScene = preload("res://addons/atlasser/assets/scenes/atlas_main_screen.tscn")

var main_panel : Control


func _enter_tree() -> void:
	main_panel = MAIN_PANEL_SCENE.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel)
	_make_visible(false)


func _exit_tree() -> void:
	if main_panel:
		main_panel.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if main_panel:
		main_panel.visible = visible


func _get_plugin_name() -> String:
	return "Atlas"


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("AtlasTexture", "EditorIcons")
