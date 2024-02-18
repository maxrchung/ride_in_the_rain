extends RigidBody3D

@export var max_lean = 10
@export var max_force = 5
var mouse_velocity = Vector2.ZERO
var current_lean = 0
var current_force = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_vel = get_viewport().get_visible_rect().size/2 - mouse_pos
	Input.warp_mouse(get_viewport().get_visible_rect().size/2)
	current_lean = -mouse_vel.x
	if(current_lean >= 0):
		if(current_lean > max_lean):
			current_lean = max_lean
	else:
		if (current_lean < 0):
			if(current_lean < -max_lean):
				current_lean = -max_lean
				
	current_force = mouse_vel.y
	if(current_force >= 0):
		if(current_force > max_force):
			current_force = max_force
	else:
		if(current_force < 0):
			current_force = 0
