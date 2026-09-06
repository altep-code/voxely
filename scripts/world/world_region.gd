extends Node3D
class_name WorldRegion

var manager: WorldManager

@export var loaded_chunks: Dictionary[Vector2i, bool] = {}
var chunks: Dictionary[Vector2i, WorldChunk] = {}

var region_coords: Vector2i


const chunk_size = 16

var render_distance = 2 * 16
var last_position
func init():
	pass

func update_position(pos: Vector3):
	last_position = pos
	do_chunks()


func do_chunks():
	for x in range(last_position.x - render_distance, last_position.x + render_distance, chunk_size):
		var xf = floor(float(x) / chunk_size )
		var local_x = xf - (region_coords.x * 32)		

		for y in range(last_position.z - render_distance, last_position.z + render_distance, chunk_size):
			var yf = floor(float(y) / chunk_size )
			var local_y = yf - (region_coords.y * 32)			

			var global_coords = Vector2i(xf, yf)
			var local_chunk_pos = Vector2i(local_x, local_y)
			

			
			if loaded_chunks.has(local_chunk_pos):
				continue
			#print("[REGION ", name, "] global: ", xf," ", yf, " local: ", local_x, " ", local_y)

			
			if local_y < 0 or local_y > 31 \
			or local_x < 0 or local_x > 31:
				continue
				
			if chunks.has(local_chunk_pos):
				var chunk: WorldChunk = chunks.get(local_chunk_pos)
				if chunk.is_data_generated:
					
					var mesh_inst := MeshInstance3D.new()
					var mesh = BoxMesh.new()
					var mat = StandardMaterial3D.new()
					mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					mat.albedo_color = Color(1.0, 1.0, 1.0, 0.035)
					mesh.material = mat
					mesh_inst.mesh = mesh
					mesh.size = Vector3(15.5, 256, 15.5)
			
					mesh_inst.position = Vector3(local_x + .5,-2,local_y + .5) * 16 
					#add_child(mesh_inst)
					
					chunk.north_neighbor = manager.find_chunk(global_coords + Vector2i.UP)
					chunk.east_neighbor = manager.find_chunk(global_coords + Vector2i.RIGHT)
					chunk.south_neighbor = manager.find_chunk(global_coords + Vector2i.DOWN)
					chunk.west_neighbor = manager.find_chunk(global_coords + Vector2i.LEFT)
					
					chunk.generate_meshes()
					
					add_child(chunk)

					loaded_chunks.set(local_chunk_pos, true)

					continue
				
				
			var chunk := WorldChunk.new()
			chunk.global_pos = Vector2i(xf, yf)
			chunk.local_region_pos = Vector2i(local_x, local_y)
			chunk.name = str(chunk.local_region_pos)
			chunk.position = Vector3(local_x, 0 , local_y) *16
			chunk.manager = manager
			chunk.north_neighbor = manager.find_chunk(global_coords + Vector2i.UP)
			chunk.east_neighbor = manager.find_chunk(global_coords + Vector2i.RIGHT)
			chunk.south_neighbor = manager.find_chunk(global_coords + Vector2i.DOWN)
			chunk.west_neighbor = manager.find_chunk(global_coords + Vector2i.LEFT)
			chunk.init()
			chunk.generate_chunk_data()
			chunk.generate_meshes()
			
			chunks.set(Vector2i(local_x, local_y), chunk)
			
			add_child(chunk)
			
			var mesh_inst := MeshInstance3D.new()
			var mesh = BoxMesh.new()
			var mat = StandardMaterial3D.new()
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color = Color(1.0, 1.0, 1.0, 0.035)
			mesh.material = mat
			mesh_inst.mesh = mesh
			mesh.size = Vector3(15.5, 256, 15.5)
			
			mesh_inst.position = Vector3(local_x + .5,-2,local_y + .5) * 16 
			
			#add_child(mesh_inst)
			
			loaded_chunks.set(Vector2i(local_x, local_y), true)

			

func generate_only_chunk_terrain(global_coords: Vector2i, chunk_coords: Vector2i):
	var chunk := WorldChunk.new()
	chunk.global_pos = global_coords
	chunk.name = str(chunk.global_pos)
	chunk.manager = manager
	chunk.init()

	

	chunk.local_region_pos = chunk_coords
	chunk.position = Vector3(chunk_coords.x, 0 , chunk_coords.y) *16
	chunk.generate_chunk_data()
			
	chunks.set(chunk_coords, chunk)
