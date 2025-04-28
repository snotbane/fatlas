## A single component copied from a [MaterializedSpriteTemplate]. Contains many [MaterializedSpriteElement]s (layers).
@tool class_name MaterializedSpriteComponent extends Node2D

const COMPONENT_KEYS = ["a", "e", "m", "n"]

enum TextureComponent {
	ALBEDO,
	EMISSIVE,
	ROUGHMAT,
	NORMAL,
}



var mirrored : bool
var component : TextureComponent
var template : MaterializedSpriteTemplate
var sprite_nodes : Dictionary


var texture_key : StringName :
	get:
		var mirrored_string : String = "l" if mirrored else "r"
		var component_string : String = COMPONENT_KEYS[component]
		return "_%s_%s" % [mirrored_string, component_string]


func populate(__template: MaterializedSpriteTemplate, __mirrored: bool, __component: TextureComponent) -> void:
	template = __template
	mirrored = __mirrored
	component = __component

	# if component == TextureComponent.ALBEDO:
	# 	self.modulate = template.modulate
	# 	self.self_modulate = template.self_modulate

	refresh()


func refresh() -> void:
	for child in self.get_children():
		child.queue_free()
	sprite_nodes.clear()

	if template == null: return

	position = template.position
	create_sprites_from_node(template)


func get_animated_sprite_current_texture(sprite: AnimatedSprite2D) -> Texture2D:
	return sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)


func create_sprites_from_node(node: Node2D) -> void:
	for child in node.get_children():
		if child is AnimatedSprite2D:
			create_sprite_from_animated_sprite_2d(child)
		elif child is Sprite2D:
			create_sprite_from_sprite_2d(child)
		elif child is Node2D:
			create_sprites_from_node(child)


func create_sprite_from_sprite_2d(sprite: Sprite2D) -> Sprite2D:
	var result := create_mesh(sprite, sprite.texture)
	return result


func create_sprite_from_animated_sprite_2d(sprite: AnimatedSprite2D) -> Sprite2D:
	var result := create_mesh(sprite, get_animated_sprite_current_texture(sprite))
	return result


func create_mesh(node: Node2D, texture: Texture2D) -> Sprite2D:
	var result := MaterializedSpriteElement.new()
	result.populate(self, node)

	# result.set_script(ELEMENT_SCRIPT)
	result.texture = texture
	result.centered = node.centered
	result.name = node.name
	set_texture(result, texture)

	self.sprite_nodes[result] = node
	self.add_child(result, false, INTERNAL_MODE_DISABLED)

	return result


func set_texture(node: Node2D, texture: Texture2D) -> void:
	node.texture = texture
	node.visible = node.texture != null


func refresh_sprite2d(node: Sprite2D) -> void:
	set_texture(node, sprite_nodes[node].texture)


func refresh_animated_sprite2d(node: Sprite2D) -> void:
	set_texture(node, get_animated_sprite_current_texture(sprite_nodes[node]))
