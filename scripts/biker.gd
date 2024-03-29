extends RigidBody3D

@export var max_lean = 65
@export var max_force = 300
var mouse_velocity = Vector2.ZERO
var current_lean = 0
var current_force = 0
var rider
@export var lean_factor = 0.4
@export var kb_lean_factor = 300
@export var kb_speed = 20
var input_vel = Vector2.ZERO
@export var mouse_lean = 7
@export var mouse_speed = 1
var mouse_vel = Vector2.ZERO
@export var pedal_speed = 2
@export var is_front = false
@export var is_rear = false
@export var scroll_speed = 4.5
@export var decay_speed = 18

# This is assigned a unique peer ID on multiplayer connection
var peer_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_front:
		get_node("FrontLight").visible = true
	if is_rear:
		get_node("RearLight").visible = true
	rider = get_node("rider")
	if multiplayer.get_unique_id() != peer_id:
		rider.material = null
	get_node("player_model/AnimationPlayer").play("spokesAction_001")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		mouse_vel = event.relative

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer.is_server():
		# Tell others about biker stuff
		update_biker.rpc(current_lean, current_force)
	
	if multiplayer.get_unique_id() != peer_id:
		get_node("player_model/AnimationPlayer").speed_scale = (current_force/max_force) * pedal_speed
		rider.rotation.z = -deg_to_rad(current_lean)
		return
		
	if $/root/Game/TestMap/LoseUi.visible or $/root/Game/TestMap/WinUi.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	input_vel.x = 0
	if Input.is_action_just_pressed("change_control_scheme"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
		if Input.is_action_pressed("kb_right"):
			input_vel.x -= kb_lean_factor
		if Input.is_action_pressed("kb_left"):
			input_vel.x += kb_lean_factor
		if Input.is_action_pressed("kb_up"):
			if(input_vel.y < max_force):
				input_vel.y += kb_speed * delta
			else:
				input_vel.y = max_force
		else:
			if(input_vel.y > 0):
				input_vel.y -= decay_speed * delta
			else:
				input_vel.y = 0
	else:
		#var mouse_pos = get_viewport().get_mouse_position()
		#var mouse_vel = get_viewport().get_visible_rect().size/2 - mouse_pos
		#Input.warp_mouse(get_viewport().get_visible_rect().size/2)
		#input_vel = mouse_vel
		if Input.is_action_just_pressed("mouse_wheel_up") || Input.is_action_just_pressed("mouse_wheel_down"):
			input_vel.y += kb_speed * delta * scroll_speed
		
		input_vel.x = -mouse_vel.x * mouse_lean
		input_vel.y += abs(mouse_vel.y) * delta * mouse_speed
		if input_vel.y > max_force:
			input_vel.y = max_force
		if(input_vel.y > 0):
			input_vel.y -= decay_speed * delta
		else:
			input_vel.y = 0
	
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
			
	# Tell server about your personal changes
	update_biker.rpc_id(1, current_lean, current_force)
	get_node("player_model/AnimationPlayer").speed_scale = (current_force/max_force) * pedal_speed
	rider.rotation.z = -deg_to_rad(current_lean)
		
@rpc("any_peer", "call_local")
func update_biker(lean, force):
	current_lean = lean
	current_force = force
	rider.rotation.z = -deg_to_rad(current_lean)
