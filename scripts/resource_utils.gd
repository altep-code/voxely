extends Node

func resolve_json_model_texture_path(texture_name: String, textures: Dictionary):
	if texture_name.begins_with("#"):
		if textures.has(texture_name.get_slice("#",1)):
			return resolve_texture_access(textures.get(texture_name.get_slice("#",1)))
		else:
			return {"texture_name": "engine:missigno", "atlas_name": "block"}
	else:
		# Its a global texture, easy.
		return resolve_texture_access(texture_name)

func resolve_texture_access(texture_path: String):
	var tex_namespace 
	if texture_path.split(":").size() == 1:
		tex_namespace = "minecraft"
	else:
		tex_namespace = texture_path.split(":")[0]
	var atlas_name = texture_path.get_slice(":",1).get_slice("/",0)
	var tex_path_arr := texture_path.get_slice(":",1).split("/")
	tex_path_arr.remove_at(0)
	var tex_path = "/".join(tex_path_arr)
	
	return {"texture_name": tex_namespace + ":" + tex_path, "atlas_name": atlas_name}
