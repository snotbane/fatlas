@tool
extends EditorPlugin

func _enter_tree() -> void:
	# _make_visible(false)
	pass


func _exit_tree() -> void:
	# if main_panel:
	# 	main_panel.queue_free()
	pass


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
