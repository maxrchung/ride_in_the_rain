extends Area3D

@export var bikers = []
@export var max_velocity = 100
@export var friction = 0.25
@export var handling = 5000
@export var biker_offset = 2.5
@export var speedFactor = 0.025
var current_velocity = 0
var current_lean = 0
var current_dir = 0
var biker_res = preload("res://gameobjects/biker.tscn")
var forward_vector = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	reset()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !multiplayer.is_server():
		return
		
	if GlobalCrap.players.size() != bikers.size():
		resync_bikers.rpc()
		
	forward_vector = get_global_transform().basis.z
	if Input.is_action_just_pressed("crash"):
		crash()
	current_lean = 0
	for biker in bikers:
		current_velocity += biker.current_force
		current_lean += biker.current_lean
	#current_lean = current_lean/bikers.size()
	#if(current_velocity > max_velocity):
	#	current_velocity = max_velocity
	#print(bikers[0].current_velocity)
	position += current_velocity * forward_vector * delta * speedFactor
	rotation.y += current_lean * delta * (current_velocity/handling)
	current_velocity -= ((current_velocity * friction) + 1) * delta
	if(current_velocity < 0):
		current_velocity = 0
		
	update_bicycle.rpc(position, rotation)
	
@rpc("call_local")
func resync_bikers():
	for biker in bikers:
		# If you try queue_free instead of free, a newly created biker may have
		# a conflicting node name which throws a bunch of RPC errors
		biker.free()
	bikers = []
	var playerCount = GlobalCrap.players.size()
	add_bikers(playerCount)

@rpc
func update_bicycle(new_position, new_rotation):
	position = new_position
	rotation = new_rotation

func reset():
	position = get_node("../StartPosition").position
	rotation = get_node("../StartPosition").rotation
	current_velocity = 0
	current_lean = 0
	resync_bikers()

func add_bikers(amt):
	for i in amt:
		var biker_instance = biker_res.instantiate()
		biker_instance.peer_id = GlobalCrap.players[i]
		var name = "Biker" + str(GlobalCrap.players[i])
		biker_instance.name = name
		
		add_child(biker_instance)
		
		# Don't set freeze true, it makes collisions (e.g. with end area) not work
		# biker_instance.freeze = true
		
		var biker_pos = Vector3.ZERO
		biker_pos.z = -biker_offset * i
		biker_instance.position = biker_pos
		bikers.append(biker_instance)
		
func crash():
	for biker in bikers:
		biker.top_level = true
		biker.freeze = false
		var randvect = Vector3.ZERO
		randvect.x = randf()
		randvect.z = randf()
		biker.apply_impulse((current_velocity * forward_vector * randvect)*100)
