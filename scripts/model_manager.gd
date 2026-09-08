extends Node

@export var MODELS: Dictionary[String, Dictionary] = {}


## Bakes the models, return false if it failed, true if it succeeded,
func bake_model(model_name: String, json: Variant) -> bool:
	var dict := {
		"parent": "",
		"vertices": PackedVector3Array(),
		"normals": PackedVector3Array(),
		"uvs": PackedVector2Array(),
		"culls": PackedStringArray()
	}
	
	
	
	
	if not json.has("elements"):
		return false
	
	if not json.has("textures"):
		return false		
	
	var textures = json.textures
	var elements = json.elements
	
	# Counts element to slightly offset to fight z_fighting (i'm tired and don't wanna add more logic right now)
	# i know this will cause issues... for not full blocks
	var el_cnt = 0
	for element in elements:
		var from := Vector3(element.from[0], element.from[1],element.from[2])/16
		var to := Vector3(element.to[0], element.to[1],element.to[2])/16
	 
		var faces = element.faces
		for face in faces:
			print(faces[face])
			
			var position = Vector2(0,0)
			var size = Vector2(0,0)
			if faces[face].has("uv"):
				position = Vector2(int(faces[face].uv[0]), int(faces[face].uv[1])) / 16
				size = Vector2(int(faces[face].uv[2]), int(faces[face].uv[3])) / 16
				
			if face == "up":
				var data = faces[face]
				var tex_path = ResourceUtils.resolve_json_model_texture_path(data.texture, textures)

				var rect: Rect2i = AtlasManager.get_atlas_coordinates(
					tex_path.atlas_name,
					tex_path.texture_name
					)

				dict.vertices.append(Vector3( to.x,  to.y,  to.z))
				dict.vertices.append(Vector3( to.x,  to.y,  from.z))
				dict.vertices.append(Vector3( from.x,  to.y,  to.z))
				dict.vertices.append(Vector3( from.x,  to.y,  from.z))
			
				dict.normals.append(Vector3.UP)
				dict.normals.append(Vector3.UP)
				dict.normals.append(Vector3.UP)
				dict.normals.append(Vector3.UP)

				var u0 = rect.position.x + position.x 
				var u1 = ( rect.size.x- rect.position.x) * size.x + rect.position.x
				var v0 = rect.position.y + position.y 
				var v1 = ( rect.size.y- rect.position.y) * size.y + rect.position.y

				dict.uvs.append(Vector2(u1, v1)) # 1, 1
				dict.uvs.append(Vector2(u1, v0)) # 1, 0
				dict.uvs.append(Vector2(u0, v1)) # 0, 1
				dict.uvs.append(Vector2(u0, v0)) # 0, 0
				
				if data.has("cullface"):
					dict.culls.append(data.get("cullface"))
				else: 
					dict.culls.append("none")
			elif face == "down":
				var data = faces[face]
				var tex_path = ResourceUtils.resolve_json_model_texture_path(data.texture, textures)

				var rect: Rect2i = AtlasManager.get_atlas_coordinates(
					tex_path.atlas_name,
					tex_path.texture_name
					)

				dict.vertices.append(Vector3( to.x,  from.y,  to.z))
				dict.vertices.append(Vector3( from.x,  from.y,  to.z))
				dict.vertices.append(Vector3( to.x,  from.y,  from.z))
				dict.vertices.append(Vector3( from.x,  from.y,  from.z))
			
				dict.normals.append(Vector3.DOWN)
				dict.normals.append(Vector3.DOWN)
				dict.normals.append(Vector3.DOWN)
				dict.normals.append(Vector3.DOWN)
				
				var u0 = rect.position.x + position.x 
				var u1 = ( rect.size.x- rect.position.x) * size.x + rect.position.x
				var v0 = rect.position.y + position.y 
				var v1 = ( rect.size.y- rect.position.y) * size.y + rect.position.y
				
				dict.uvs.append(Vector2(u1, v1)) # 1, 1
				dict.uvs.append(Vector2(u0, v1)) # 0, 1
				dict.uvs.append(Vector2(u1, v0)) # 1, 0
				dict.uvs.append(Vector2(u0, v0)) # 0, 0
				
				if data.has("cullface"):
					dict.culls.append(data.get("cullface"))
				else: 
					dict.culls.append("none")
				
			elif face == "north":
				var data = faces[face]
				var tex_path = ResourceUtils.resolve_json_model_texture_path(data.texture, textures)

				var rect: Rect2i = AtlasManager.get_atlas_coordinates(
					tex_path.atlas_name,
					tex_path.texture_name
					)

				dict.vertices.append(Vector3( from.x,  to.y,  from.z))
				dict.vertices.append(Vector3( to.x,  to.y,  from.z))
				dict.vertices.append(Vector3( from.x,  from.y,  from.z))
				dict.vertices.append(Vector3( to.x,  from.y,  from.z))
			
				dict.normals.append(Vector3.FORWARD)
				dict.normals.append(Vector3.FORWARD)
				dict.normals.append(Vector3.FORWARD)
				dict.normals.append(Vector3.FORWARD)

				var u0 = rect.position.x + position.x 
				var u1 = ( rect.size.x- rect.position.x) * size.x + rect.position.x
				var v0 = rect.position.y + position.y 
				var v1 = ( rect.size.y- rect.position.y) * size.y + rect.position.y

				dict.uvs.append(Vector2(u0, v0)) # 0, 0
				dict.uvs.append(Vector2(u1, v0)) # 1, 0
				dict.uvs.append(Vector2(u0, v1)) # 0, 1
				dict.uvs.append(Vector2(u1, v1)) # 1, 1
				
				if data.has("cullface"):
					dict.culls.append(data.get("cullface"))
				else: 
					dict.culls.append("none")
			elif face == "south":
				var data = faces[face]
				var tex_path = ResourceUtils.resolve_json_model_texture_path(data.texture, textures)

				var rect: Rect2i = AtlasManager.get_atlas_coordinates(
					tex_path.atlas_name,
					tex_path.texture_name
					)

				dict.vertices.append(Vector3( from.x,  to.y,  to.z))
				dict.vertices.append(Vector3( from.x,  from.y,  to.z))
				dict.vertices.append(Vector3( to.x,  to.y,  to.z))
				dict.vertices.append(Vector3( to.x,  from.y,  to.z))
			
				dict.normals.append(Vector3.BACK)
				dict.normals.append(Vector3.BACK)
				dict.normals.append(Vector3.BACK)
				dict.normals.append(Vector3.BACK)
				
				var u0 = rect.position.x + position.x 
				var u1 = ( rect.size.x- rect.position.x) * size.x + rect.position.x
				var v0 = rect.position.y + position.y 
				var v1 = ( rect.size.y- rect.position.y) * size.y + rect.position.y
				
				dict.uvs.append(Vector2(u0, v0)) # 0, 0
				dict.uvs.append(Vector2(u0, v1)) # 0, 1
				dict.uvs.append(Vector2(u1, v0)) # 1, 0
				dict.uvs.append(Vector2(u1, v1)) # 1, 1
				

				
				
				if data.has("cullface"):
					dict.culls.append(data.get("cullface"))
				else: 
					dict.culls.append("none")
			elif face == "east":
				var data = faces[face]
				var tex_path = ResourceUtils.resolve_json_model_texture_path(data.texture, textures)

				var rect: Rect2i = AtlasManager.get_atlas_coordinates(
					tex_path.atlas_name,
					tex_path.texture_name
					)

				dict.vertices.append(Vector3( to.x,  to.y,  from.z))
				dict.vertices.append(Vector3( to.x,  to.y,  to.z))
				dict.vertices.append(Vector3( to.x,  from.y,  from.z))
				dict.vertices.append(Vector3( to.x,  from.y,  to.z))
			
				dict.normals.append(Vector3.RIGHT)
				dict.normals.append(Vector3.RIGHT)
				dict.normals.append(Vector3.RIGHT)
				dict.normals.append(Vector3.RIGHT)
			
				var u0 = rect.position.x + position.x 
				var u1 = ( rect.size.x- rect.position.x) * size.x + rect.position.x
				var v0 = rect.position.y + position.y 
				var v1 = ( rect.size.y- rect.position.y) * size.y + rect.position.y
				
				dict.uvs.append(Vector2(u0, v0)) # 0, 0
				dict.uvs.append(Vector2(u1, v0)) # 1, 0
				dict.uvs.append(Vector2(u0, v1)) # 0, 1
				dict.uvs.append(Vector2(u1, v1)) # 1, 1
				
				if data.has("cullface"):
					dict.culls.append(data.get("cullface"))
				else: 
					dict.culls.append("none")
			elif face == "west":
				var data = faces[face]
				var tex_path = ResourceUtils.resolve_json_model_texture_path(data.texture, textures)

				var rect: Rect2i = AtlasManager.get_atlas_coordinates(
					tex_path.atlas_name,
					tex_path.texture_name
					)

				dict.vertices.append(Vector3( from.x,  to.y,  from.z))
				dict.vertices.append(Vector3( from.x,  from.y,  from.z))
				dict.vertices.append(Vector3( from.x,  to.y,  to.z))
				dict.vertices.append(Vector3( from.x,  from.y,  to.z))
			
				dict.normals.append(Vector3.LEFT)
				dict.normals.append(Vector3.LEFT)
				dict.normals.append(Vector3.LEFT)
				dict.normals.append(Vector3.LEFT)

				var u0 = rect.position.x + position.x 
				var u1 = ( rect.size.x- rect.position.x) * size.x + rect.position.x
				var v0 = rect.position.y + position.y 
				var v1 = ( rect.size.y- rect.position.y) * size.y + rect.position.y
				
				dict.uvs.append(Vector2(u0, v0)) # 0, 0
				dict.uvs.append(Vector2(u0, v1)) # 0, 1
				dict.uvs.append(Vector2(u1, v0)) # 1, 0
				dict.uvs.append(Vector2(u1, v1)) # 1, 1
				
				if data.has("cullface"):
					dict.culls.append(data.get("cullface"))
				else: 
					dict.culls.append("none")
	
	MODELS.set(model_name, dict)
	return true


func get_model(model_name: String):
	if MODELS.has(model_name):
		return MODELS.get(model_name)
	else:
		return null
