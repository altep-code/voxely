extends Node3D
class_name WorldChunk

var manager: WorldManager
var region: WorldRegion

var north_neighbor: WorldChunk
var east_neighbor: WorldChunk
var south_neighbor: WorldChunk
var west_neighbor: WorldChunk

var is_data_generated: bool = false


var chunk_data: WorldChunkData
var local_region_pos: Vector2i
var global_pos: Vector2i

var CHUNK_COLLIDER:= PackedVector3Array()
var FULL_BLOCK_MESH: MeshInstance3D

var static_body: StaticBody3D
var collision_shape: CollisionShape3D
var concave_shape: ConcavePolygonShape3D

const SHADER: Shader = preload("res://chunks.gdshader")

func init():
	static_body = StaticBody3D.new()
	collision_shape = CollisionShape3D.new()
	concave_shape = ConcavePolygonShape3D.new()
	
	collision_shape.shape = concave_shape
	
	add_child(static_body)
	static_body.add_child(collision_shape)
	
	FULL_BLOCK_MESH = MeshInstance3D.new()
	add_child(FULL_BLOCK_MESH)


func generate_meshes():
	CHUNK_COLLIDER.clear()
	generate_full_blocks()
	
	concave_shape.set_faces(CHUNK_COLLIDER)



func generate_full_blocks():
	manager.chunk_count +=1
	print("Loaded chunks: ", manager.chunk_count)
	var INDECIES:= PackedInt32Array()
	var NORMALS := PackedVector3Array()
	var VERTEX:= PackedVector3Array()
	var UV:= PackedVector2Array()
	
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	
	var time = Time.get_ticks_msec()

	var vert_cnt = 0
	for block_pos in chunk_data.blocks:
		var block = chunk_data.blocks.get(block_pos)
		var palette = chunk_data.palette.get(block)
		
		var rect: Rect2i = AtlasManager.get_atlas_coordinates("blocks", palette)
		
		# Below is what i call the behemoth, goliath, or even the monolith, it works, don't tweak anything
		# If you haven't looked at the line count... you will notice this is only the first one.
		# AKA The Full Block Goliath
		# Top face
		if not chunk_data.blocks.has(vec3_to_index(index_to_vec3(block_pos) + Vector3i.UP)):
			#print(index_to_vec3(block_pos))
			var vec = index_to_vec3(block_pos)
			#print(vec)
			VERTEX.append(Vector3(vec) + Vector3( 1,  1,  1))
			VERTEX.append(Vector3(vec) + Vector3( 1,  1,  0))
			VERTEX.append(Vector3(vec) + Vector3( 0,  1,  1))
			VERTEX.append(Vector3(vec) + Vector3( 0,  1,  0))
			
			NORMALS.append(Vector3.UP)
			NORMALS.append(Vector3.UP)
			NORMALS.append(Vector3.UP)
			NORMALS.append(Vector3.UP)
			
			
			UV.append(Vector2(rect.size.x, rect.size.y)) # 1, 1
			UV.append(Vector2(rect.size.x, rect.position.y)) # 1, 0
			UV.append(Vector2(rect.position.x, rect.size.y)) # 0, 1
			UV.append(Vector2(rect.position.x, rect.position.y)) # 0, 0

			CHUNK_COLLIDER.append(VERTEX[vert_cnt])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 3])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])

			INDECIES.append(vert_cnt)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 1)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 3)
			INDECIES.append(vert_cnt + 1)
			
			vert_cnt += 4
		if not chunk_data.blocks.has(vec3_to_index(index_to_vec3(block_pos) + Vector3i.DOWN)):
			#print(index_to_vec3(block_pos))
			var vec = index_to_vec3(block_pos)
			#print(vec)
			VERTEX.append(Vector3(vec) + Vector3( 1,  0,  1))
			VERTEX.append(Vector3(vec) + Vector3( 0,  0,  1))
			VERTEX.append(Vector3(vec) + Vector3( 1,  0,  0))
			VERTEX.append(Vector3(vec) + Vector3( 0,  0,  0))
			
			NORMALS.append(Vector3.DOWN)
			NORMALS.append(Vector3.DOWN)
			NORMALS.append(Vector3.DOWN)
			NORMALS.append(Vector3.DOWN	)
			
			
			UV.append(Vector2(rect.size.x, rect.size.y)) # 1, 1
			UV.append(Vector2(rect.position.x, rect.size.y)) # 0, 1
			UV.append(Vector2(rect.size.x, rect.position.y)) # 1, 0
			UV.append(Vector2(rect.position.x, rect.position.y)) # 0, 0

			CHUNK_COLLIDER.append(VERTEX[vert_cnt])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 3])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			
			INDECIES.append(vert_cnt)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 1)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 3)
			INDECIES.append(vert_cnt + 1)
			
			vert_cnt += 4
		
		
		if not _do_stuff_that_checks_neighbor_blocks(block_pos, Vector3i.FORWARD):
			var vec = index_to_vec3(block_pos)
			#print(vec)
			VERTEX.append(vec + Vector3i( 0,  1, 0))
			VERTEX.append(vec + Vector3i( 1,  1, 0))
			VERTEX.append(vec + Vector3i( 0,  0, 0))
			VERTEX.append(vec + Vector3i( 1,  0, 0))
			
			NORMALS.append(Vector3.FORWARD)
			NORMALS.append(Vector3.FORWARD)
			NORMALS.append(Vector3.FORWARD)
			NORMALS.append(Vector3.FORWARD)

			UV.append(Vector2(rect.position.x, rect.position.y)) # 0, 0
			UV.append(Vector2(rect.size.x, rect.position.y)) # 1, 0
			UV.append(Vector2(rect.position.x, rect.size.y)) # 0, 1
			UV.append(Vector2(rect.size.x, rect.size.y)) # 1, 1
			
			CHUNK_COLLIDER.append(VERTEX[vert_cnt])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 3])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			
			INDECIES.append(vert_cnt)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 1)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 3)
			INDECIES.append(vert_cnt + 1)

			vert_cnt += 4
		if not _do_stuff_that_checks_neighbor_blocks(block_pos, Vector3i.RIGHT):
			var vec = index_to_vec3(block_pos)
			#print(vec)
			VERTEX.append(vec + Vector3i( 1,  1, 0))
			VERTEX.append(vec + Vector3i( 1,  1, 1))
			VERTEX.append(vec + Vector3i( 1,  0, 0))
			VERTEX.append(vec + Vector3i( 1,  0, 1))
			
			NORMALS.append(Vector3.RIGHT)
			NORMALS.append(Vector3.RIGHT)
			NORMALS.append(Vector3.RIGHT)
			NORMALS.append(Vector3.RIGHT)

			UV.append(Vector2(rect.position.x, rect.position.y)) # 0, 0
			UV.append(Vector2(rect.size.x, rect.position.y)) # 1, 0
			UV.append(Vector2(rect.position.x, rect.size.y)) # 0, 1
			UV.append(Vector2(rect.size.x, rect.size.y)) # 1, 1
			
			CHUNK_COLLIDER.append(VERTEX[vert_cnt])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 3])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			
			INDECIES.append(vert_cnt)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 1)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 3)
			INDECIES.append(vert_cnt + 1)

			vert_cnt += 4
			
		if not _do_stuff_that_checks_neighbor_blocks(block_pos, Vector3i.BACK):
			var vec = index_to_vec3(block_pos)
			#print(vec)
			VERTEX.append(vec + Vector3i( 0,  1, 1))
			VERTEX.append(vec + Vector3i( 0,  0, 1))
			VERTEX.append(vec + Vector3i( 1,  1, 1))
			VERTEX.append(vec + Vector3i( 1,  0, 1))
			
			NORMALS.append(Vector3.BACK)
			NORMALS.append(Vector3.BACK)
			NORMALS.append(Vector3.BACK)
			NORMALS.append(Vector3.BACK)

			UV.append(Vector2(rect.position.x, rect.position.y)) # 0, 0
			UV.append(Vector2(rect.position.x, rect.size.y)) # 0, 1
			UV.append(Vector2(rect.size.x, rect.position.y)) # 1, 0
			UV.append(Vector2(rect.size.x, rect.size.y)) # 1, 1
			
			CHUNK_COLLIDER.append(VERTEX[vert_cnt])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 3])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			
			INDECIES.append(vert_cnt)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 1)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 3)
			INDECIES.append(vert_cnt + 1)
			vert_cnt += 4

			
		if not _do_stuff_that_checks_neighbor_blocks(block_pos, Vector3i.LEFT):
			var vec = index_to_vec3(block_pos)
			#print(vec)
			VERTEX.append(vec + Vector3i( 0,  1, 0))
			VERTEX.append(vec + Vector3i( 0,  0, 0))
			VERTEX.append(vec + Vector3i( 0,  1, 1))
			VERTEX.append(vec + Vector3i( 0,  0, 1))
			
			NORMALS.append(Vector3.LEFT)
			NORMALS.append(Vector3.LEFT)
			NORMALS.append(Vector3.LEFT)
			NORMALS.append(Vector3.LEFT)

			UV.append(Vector2(rect.position.x, rect.position.y)) # 0, 0
			UV.append(Vector2(rect.position.x, rect.size.y)) # 0, 1
			UV.append(Vector2(rect.size.x, rect.position.y)) # 1, 0
			UV.append(Vector2(rect.size.x, rect.size.y)) # 1, 1
			
			CHUNK_COLLIDER.append(VERTEX[vert_cnt])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 2])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 3])
			CHUNK_COLLIDER.append(VERTEX[vert_cnt + 1])
			
			INDECIES.append(vert_cnt)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 1)
			INDECIES.append(vert_cnt + 2)
			INDECIES.append(vert_cnt + 3)
			INDECIES.append(vert_cnt + 1)

			vert_cnt += 4
	
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = VERTEX
	arrays[Mesh.ARRAY_INDEX] = INDECIES
	arrays[Mesh.ARRAY_NORMAL] = NORMALS
	arrays[Mesh.ARRAY_TEX_UV] = UV
	
	print("Vert: ",VERTEX.size())
	#print("Inde: ",INDECIES.size())
	#print("UVs:  ", UV.size())
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	#print(arr_mesh.get_surface_count())
	FULL_BLOCK_MESH.mesh = arr_mesh
	apply_texture(FULL_BLOCK_MESH, "res://dirt.png")
	
	var elapsed_time = Time.get_ticks_msec() - time
	print("Chunk took: ", elapsed_time, " ms")



# Blocks that can have some surfaces not rendered with full blocks too
func generate_cutouts_blocks():
	pass
	
# Blocks that require custom shader since transparency
func generate_transparent_blocks():
	pass

# Non-full blocks that don't affect others
func generate_model_blocks():
	pass

func generate_transparent_fluids():
	pass
	
func generate_solid_fluids():
	pass 

## I don't have a freaking name for this function, this will now be permanent.
func _do_stuff_that_checks_neighbor_blocks(block_pos: int, direction: Vector3i):
	var check = index_to_vec3(block_pos) + direction
	if check.x < 0 or check.x > 15 \
	or check.z < 0 or check.z > 15: 
	
		var chunk: WorldChunk
		match direction:
			Vector3i.FORWARD:
				chunk = north_neighbor
				check.z += 16
			Vector3i.RIGHT:
				chunk = east_neighbor
				check.x -= 16
			Vector3i.BACK:
				chunk = south_neighbor
				check.z -= 16
			Vector3i.LEFT:
				chunk = west_neighbor
				check.x += 16
			_:
				return null
		var blocks = chunk.chunk_data.blocks
		
		var block = blocks.has(vec3_to_index(check))
		return block
	else:
		var blocks = chunk_data.blocks
		var block = blocks.has(vec3_to_index(check))
		return block
		
		


func generate_chunk_data():
	chunk_data = WorldChunkData.new()
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.offset = Vector3(global_pos.x, global_pos.y, 0) * 16 	 
	
	var blocks: Dictionary[int, int]= {}
	
	
	
	for x in range(16):
		for z in range(16):
			var pos = Vector2(x,z)
			var height = floor(noise.get_noise_2d(x,z) * 16+20)
			height  = 16
			for y in range(height):
			
				if y == height-1:
					set_block(Vector3i(x,y,z), "moss_block.png")
				elif y <= height-4:
					set_block(Vector3i(x,y,z), "stone.png")
				else: 
					set_block(Vector3i(x,y,z), "dirt.png")

			
			#print("CHUNK ", x, " ", y, " ", height )
	
	is_data_generated = true
	
func vec3_to_index(vec: Vector3i) -> int:
	return vec.x + (vec.z * 16) + (vec.y * 16 * 384 )

func index_to_vec3(index: int) -> Vector3i:
	var y = index / (16 * 384)
	var rem = index % (16 * 384)
	var z = rem / 16
	var x = rem % 16
	return Vector3i(x, y, z)

func apply_texture(mesh_instance_node, texture_path):
	
	var texture = AtlasManager.get_atlas("blocks")
	
	if texture == null:
		print("oops... too early...")
	
	var mat = ShaderMaterial.new()
	mat.shader = SHADER

	mat.set_shader_parameter("atlas", texture)
	# mat.roughness = 1
	#mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	#mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	#mat.albedo_texture = texture
	#mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST 
	
	mesh_instance_node.material_override = mat

## Use this function to edit chunks, an external script should never edit chunk data
## Returns false if the block didn't change, true otherwise
func set_block(vec: Vector3i, block_identifier: String) -> bool:
	var palette = chunk_data.palette.find_key(block_identifier)
	var index = vec3_to_index(vec)
	
	if block_identifier == "air":
		chunk_data.blocks.erase(index)
		return true

	if palette != null: 
		chunk_data.blocks.set(index, palette)
		return true
	else: 
		var i = 0
		while chunk_data.palette.has(i):
			i+=1
		chunk_data.palette.set(i, block_identifier)
		chunk_data.blocks.set(index, i)
		return true

		
		
	return false
