extends Camera3D

@export var follow_scan_radius: float
@export var player_target: NodePath
@onready var target = get_node(player_target)

@export var player_rotation_target: NodePath
@onready var target_rotation = get_node(player_rotation_target)

func _ready():
	size = follow_scan_radius
	
func _process(delta):
	position = Vector3(target.position.x, 30, target.position.z)
	rotation_degrees.y = target_rotation.rotation_degrees.y
