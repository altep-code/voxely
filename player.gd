extends Node3D

@export var attach_to: Node

@onready var world: WorldManager	 = $"../WorldManager"

var time:= Time.get_ticks_msec()


var box =  _create_wireframe_box(Vector3(1.01,1.01,1.01))
var box_mesh = MeshInstance3D.new()
func _ready():
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED # Keeps it bright green without scene lighting affecting it
	mat.vertex_color_use_as_albedo = true

	box_mesh.material_overlay = mat
	add_child(box_mesh)
	box_mesh.mesh = box

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	var space_state = get_world_3d().direct_space_state
	var cam = attach_to
	var cast_pos = get_viewport().size /2

	var origin = cam.project_ray_origin(cast_pos)
	var end = origin + cam.project_ray_normal(cast_pos) * 4.5
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	#print(result)
	if result:
		var snap_position = floor(result.position -	 result.normal * 0.5) + Vector3(0.5, 0.5, 0.5)
		box_mesh.position = snap_position
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Time.get_ticks_msec() - time > 75:
			#print("Snap: ",snap_position)
			world.set_block(snap_position, "air")
			time = Time.get_ticks_msec()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and Time.get_ticks_msec() - time > 75:
			#print("Snap: ",snap_position)
			world.set_block(snap_position + result.normal, "cobblestone.png")
			time = Time.get_ticks_msec()
		
	
	
func _create_wireframe_box(size: Vector3) -> ImmediateMesh:
	var imm_mesh = ImmediateMesh.new()
	var h = size / 2.0

	# Les 8 sommets du cube
	var p = [
		Vector3(-h.x, -h.y, -h.z), Vector3(h.x, -h.y, -h.z),
		Vector3(h.x, -h.y,  h.z), Vector3(-h.x, -h.y,  h.z),
		Vector3(-h.x,  h.y, -h.z), Vector3(h.x,  h.y, -h.z),
		Vector3(h.x,  h.y,  h.z), Vector3(-h.x,  h.y,  h.z)
	]

	# Les 12 arêtes du cube (paires de points)
	var indices = [
		# Face du bas
		0, 1,  1, 2,  2, 3,  3, 0,
		# Face du haut
		4, 5,  5, 6,  6, 7,  7, 4,
		# Montants verticaux
		0, 4,  1, 5,  2, 6,  3, 7
	]
	
	

	imm_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for idx in indices:
		imm_mesh.surface_set_color(Color(0.0, 0.0, 0.0, 0.7))
		imm_mesh.surface_add_vertex(p[idx])
	imm_mesh.surface_end()

	return imm_mesh
