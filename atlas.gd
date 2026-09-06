extends Image
class_name ImageAtlas

var textures: Dictionary[String, AtlasTextureDef]

func get_stitched_texture(texture_folder: String):
	var tex_dir = DirAccess.open(texture_folder)
	var coords: Dictionary[String, Rect2i]= {}
	if tex_dir:
		var files := tex_dir.get_files()
		
		var res = _get_resolution_from_texture_count(files.size())
		
		var atlas = ImageAtlas.create(res, res, true, FORMAT_RGBA8)
		
		var remove = []
		for file in files:
			if file.ends_with(".import") or file.ends_with(".mcmeta"):
				remove.append(file)
				continue
				
			#var img := Image.load_from_file(texture_folder.path_join(file))
			
		for item in remove:
			files.erase(item)
		
		for i in range(files.size()):
			
			var y = i/(res/16) * 16
			var x = i % (res/16) * 16
			var rect = Rect2i(Vector2i(0,0), Vector2i(16, 16))
			
			print(i/(res/16), ", ", i % (res/16), " ", files[i])
			var img := load(texture_folder.path_join(files[i]))
			if img is Image: 
				if img.is_compressed():
					img.decompress()
				img.convert(atlas.get_format())
				
				coords.set(files[i], Rect2i(Vector2i(x,y)/16, Vector2i(x+16,y+16)/16))
				
				atlas.blit_rect(img, rect, Vector2i(x,y))
			elif img is Texture2D:
				print("no.")
			else:
				print("Guess i'll die")
			
		return {"IMAGE": atlas, "COORDINATES": coords}
			
	else: 
		print("Unable to load the specified texture folder: ", texture_folder)
	
	
func _get_resolution_from_texture_count(size):
	if size <= 128**2:
		return 1024
	else:
		return 4096

class AtlasTextureDef:
	## position in pixels
	var position: Vector2i
	## size in pixels
	var size: Vector2i
