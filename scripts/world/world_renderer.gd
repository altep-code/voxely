extends Node
class_name WorldManager

@export var loaded_regions: Dictionary[Vector2i, bool] = {}
var regions: Dictionary[Vector2i, WorldRegion] = {}

@onready var region_storage_node: Node = $Regions

const CHUNKS_PER_REGION: int = 32

var region_size = 512
var render_distance = 7 #1024

var last_position: Vector3

var chunk_count = 0

func _ready() -> void:
	pass
	_check_and_update_chunks(true)

func _process(delta: float) -> void:
	pass
	_check_and_update_chunks(false)

func init():
	pass

func _check_and_update_chunks(force: bool) -> void:	
	var camera = get_viewport().get_camera_3d()
	if not is_instance_valid(camera):
		return
		
	var player_cam = camera.global_position
	if force or last_position == null or last_position.distance_to(player_cam) > 1:
		last_position = player_cam
		
		_on_camera_movement()


func _on_camera_movement():
	_do_regions()
	_remove_distant_chunks()

func _generate_new_chunks():
	pass
	
func _remove_distant_chunks():
	pass


func _do_regions():
	
	var half_region = region_size/2
	
	# Those loops run on hopes and dream, no touchy
	for x in range(last_position.x - render_distance, last_position.x + render_distance, region_size):
		var xf = floor(float(x) / region_size )

		for y in range(last_position.z - render_distance, last_position.z + render_distance, region_size):
			var yf = floor(float(y) / region_size )
			
			if loaded_regions.has(Vector2i(xf, yf)):
				continue
			
			var region = WorldRegion.new()
			region.region_coords = Vector2i(xf, yf)
			region.manager = self

			region.name = str(Vector2i(xf, yf)) 
			region.position = Vector3(xf,0,yf) * 512 
			region.init()
			
			region_storage_node.add_child(region)
			regions.set(Vector2i(xf, yf), region)
			
			var mesh_inst := MeshInstance3D.new()
			var mesh = BoxMesh.new()
			mesh_inst.mesh = mesh
			mesh.size = Vector3(511, 0.1, 511)
			
			mesh_inst.position = Vector3(xf + .5,0,yf + .5) * 512 
			
			#add_child(mesh_inst)
			
			
			
			loaded_regions.set(Vector2i(xf, yf), true)
			
	for region_pos in regions:
		var region: WorldRegion = regions.get(region_pos)
		if not is_instance_valid(region):
			print("Invalid region in cache.")
			continue
		region.update_position(last_position)

## Return the chunk if loaded, else nothing.
func find_chunk(global_coords: Vector2i):
	var region_coord = _find_regions_of_chunk(global_coords)
	if regions.has(region_coord):
		var world_region: WorldRegion = regions.get(region_coord)
		var local_chunk_coord = _find_local_coords_of_chunk(region_coord, global_coords)
		var chunk: WorldChunk
		if world_region.chunks.has(local_chunk_coord):
			chunk = world_region.chunks.get(local_chunk_coord)
		else:
			world_region.generate_only_chunk_terrain(global_coords, local_chunk_coord)
			chunk = world_region.chunks.get(local_chunk_coord)
		return chunk
	else: 
		var region = WorldRegion.new()
		region.region_coords = region_coord
		region.manager = self
		region.name = str(region_coord) 
		region.position = Vector3(region_coord.x,0,region_coord.y) * 512 
		region.init()
			
		region_storage_node.add_child(region)
		regions.set(region_coord, region)
		loaded_regions.set(region_coord, true)
		
		return find_chunk(global_coords)

	
	

func _find_regions_of_chunk(global_coords: Vector2i):
	var chunk_x = float(global_coords.x)
	var chunk_y = float(global_coords.y)
	
	var region_x = floor(chunk_x / 32.0)
	var region_y = floor(chunk_y / 32.0)
	
	return Vector2i(region_x, region_y)

func _find_local_coords_of_chunk(region_coords: Vector2i, chunk_global_coords: Vector2i):
	return Vector2i(
		posmod(chunk_global_coords.x, CHUNKS_PER_REGION),
		posmod(chunk_global_coords.y, CHUNKS_PER_REGION)
	)
	

func set_block(pos: Vector3, identifier: String):
	var pos_x = float(pos.x)
	var pos_y = float(pos.z)
	
	var posi := Vector3i(floor(pos_x), pos.y, floor(pos_y))
	var chunk_glob_coord = Vector2i(floor(pos_x / 16.0), floor(pos_y / 16.0))
	var region_coord = _find_regions_of_chunk(chunk_glob_coord)
	var local_coord = _find_local_coords_of_chunk(region_coord, chunk_glob_coord)
	
	if regions.has(region_coord):
		var region: WorldRegion = regions.get(region_coord)
		if region.chunks.has(local_coord):
			var chunk: WorldChunk = region.chunks.get(local_coord)
			var local_pos = _global_to_local_block(posi, chunk_glob_coord)
			var is_set = chunk.set_block(local_pos, identifier)
			if is_set:
				chunk.generate_meshes()
				if local_pos.x == 0: 
					chunk.west_neighbor.generate_meshes()
				if local_pos.z == 0: 
					chunk.north_neighbor.generate_meshes()
				if local_pos.x == 15: 
					chunk.east_neighbor.generate_meshes()
				if local_pos.z == 15: 
					chunk.south_neighbor.generate_meshes()
			print("[CHUNK", local_coord, "]Local v. Global", local_pos, " ", posi)
	else: 
		print("Sir, we fucked up and are somehow breaking blocks in an non-existent region... or you are hacking.")
	
	
	
func _global_to_local_block(global_pos: Vector3i, chunk_coords: Vector2i) -> Vector3i:
	var lx = global_pos.x - chunk_coords.x * 16 
	var lz = global_pos.z - chunk_coords.y * 16 

	
	return Vector3i(lx, global_pos.y, lz)
