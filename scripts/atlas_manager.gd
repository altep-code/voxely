extends Node

var ATLASES: Dictionary[String, ImageTexture] = {}
var COORDS: Dictionary[String, Dictionary] = {}

func add_atlas(name: String, atlas_texture: ImageTexture):
	ATLASES.set(name, atlas_texture)

## Name corespond to the atlas name others will search, doesn't have to match but should 
func add_atlas_coordinates(name: String, atlas_coords: Dictionary[String, Rect2i]):
	COORDS.set(name, atlas_coords)

func get_atlas(atlas_name: String):
	if ATLASES.has(atlas_name):
		return ATLASES.get(atlas_name)
	return null
	
func get_atlas_coordinates(atlas_name: String, texture_name: String):
	if COORDS.has(atlas_name):
		var atlas_coords: Dictionary[String, Rect2i] = COORDS.get(atlas_name)
		if atlas_coords.has(texture_name):
			return atlas_coords.get(texture_name)
	return Rect2i(Vector2i(0,0), Vector2i(1,1))
