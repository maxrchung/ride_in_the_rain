extends Camera3D

@export var camera_target: NodePath
@onready var target = get_node(camera_target)

var lerp_speed: float = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if multiplayer.is_server():
		basis = Quaternion(basis).slerp(Quaternion(target.global_basis), delta * lerp_speed)
		position = position.lerp(target.global_position, delta * lerp_speed)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(global_position)
	#print(global_rotation)
	#print(position)
	#print(rotation)
	#print(target.global_position)
	#print(target.global_rotation)
	#print(target.position)
	#print(target.rotation)
	#print()
	
	#position = target.global_position
	#rotation = target.global_rotation
	
	#if !multiplayer.is_server():
		#basis = target.global_basis
		#position = target.global_position
		#print(position)

	
	#if (target.global_position - position).length() < 0.01:
		#position = target.global_position
	#else:
	
	#basis = target.global_basis
	#position = target.global_position
		#position = target.global_position

		#basis = Quaternion(basis).slerp(Quaternion(target.global_basis), delta * lerp_speed)
	if !multiplayer.is_server():
		basis = Quaternion(basis).slerp(Quaternion(target.global_basis), delta * lerp_speed)
		position = position.lerp(target.global_position, delta * lerp_speed)
	
	#print(position)
	
	
	#basis = Quaternion(basis).slerp(Quaternion(target.global_basis), 0.5)
	#position = position.lerp(target.global_position, delta * lerp_speed)
	pass

@rpc
func update_camera(new_position, new_basis):
	position = position.lerp(new_position, 0.1)
	basis = basis.slerp(new_basis, 0.1)
