extends Node

@export var imgt: ImageTexture
@onready var rect: TextureRect = $'LoadingMenu/TextureRect'
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("GPU Vendor: ", RenderingServer.get_video_adapter_vendor())
	print("GPU Name: ", RenderingServer.get_video_adapter_name())
	print("Driver Version: ", RenderingServer.get_video_adapter_api_version())
	_stitch_atlases()
	_do_models()


func _stitch_atlases():
	var block_atlas = ImageAtlas.new()
	
	var dict = block_atlas.get_stitched_texture(["minecraft"],["res://minecraft/textures/block"])
	
	var img = dict.IMAGE
	var coords = dict.COORDINATES
	
	imgt = ImageTexture.create_from_image(img)
	rect.texture = imgt
	
	AtlasManager.add_atlas("block", imgt)
	AtlasManager.add_atlas_coordinates("block", coords)

func _do_models():
	var models_folder = ["res://minecraft/models/block/"]
	
	for folder in models_folder: 
		var models_dir = DirAccess.open(folder)
		if models_dir:
			var files := models_dir.get_files()
			for file in files:
				#print(file)

				var json_text := FileAccess.get_file_as_string(folder.path_join(file))
				var json = JSON.new()
				var error = json.parse(json_text)
				if error == OK:
					var data = json.data
					ModelManager.bake_model("minecraft:" +  file.get_basename(), data)
				else :
					push_error("Error: ", error)
		
