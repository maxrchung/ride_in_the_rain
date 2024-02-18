extends RigidBody3D

@export var max_lean = 65
@export var max_force = 10
var mouse_velocity = Vector2.ZERO
var current_lean = 0
var current_force = 0
var rider
@export var lean_factor = 0.4
@export var kb_lean_factor = 500
@export var kb_speed = 500

# This is assigned a unique peer ID on multiplayer connection
var peer_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rider = get_node("rider")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer.get_unique_id() != peer_id:
		return
	
	
	var input_vel = Vector2.ZERO
	#var mouse_pos = get_viewport().get_mouse_position()
	#var mouse_vel = get_viewport().get_visible_rect().size/2 - mouse_pos
	#Input.warp_mouse(get_viewport().get_visible_rect().size/2)
	#input_vel = mouse_vel
	
	if Input.is_action_pressed("kb_right"):
		input_vel.x -= kb_lean_factor
	if Input.is_action_pressed("kb_left"):
		input_vel.x += kb_lean_factor
	if Input.is_action_pressed("kb_up"):
		input_vel.y = max_force
	
	current_lean += input_vel.x * delta * lean_factor
	if(current_lean >= 0):
		if(current_lean > max_lean):
			current_lean = max_lean
	else:
		if (current_lean < 0):
			if(current_lean < -max_lean):
				current_lean = -max_lean
				
	current_force = input_vel.y
	if(current_force >= 0):
		if(current_force > max_force):
			current_force = max_force
	else:
		if(current_force < 0):
			current_force = 0
			
		
	update_biker.rpc_id(1, current_lean, current_force)
	rider.rotation.z = -deg_to_rad(current_lean)
		
@rpc("any_peer", "call_local")
func update_biker(lean, force):
	current_lean = lean
	current_force = force
	rider.rotation.z = -deg_to_rad(current_lean)
