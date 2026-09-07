extends Node

@export var imgt: ImageTexture
@onready var rect: TextureRect = $'LoadingMenu/TextureRect'
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_stitch_atlases()


func _stitch_atlases():
	var block_atlas = ImageAtlas.new()
	
	var dict = block_atlas.get_stitched_texture(["minecraft"],["res://minecraft/textures/block"])
	
	var img = dict.IMAGE
	var coords = dict.COORDINATES
	
	imgt = ImageTexture.create_from_image(img)
	rect.texture = imgt
	
	AtlasManager.add_atlas("blocks", imgt)
	AtlasManager.add_atlas_coordinates("blocks", coords)
