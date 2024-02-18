extends Node

var map_scene = preload("res://maps/test_map.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Players: ", GlobalCrap.players)
	print("I am: ", multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	var map_instance = map_scene.instantiate()
	add_child(map_instance)

func _on_player_connected(id):
	if multiplayer.is_server():
		print("Player ", id, " connected")
		GlobalCrap.players.push_back(id)
		update_players.rpc(GlobalCrap.players)

func _on_player_disconnected(id):
	if multiplayer.is_server():
		print("Player ", id, " disconnected")
		GlobalCrap.players = GlobalCrap.players.filter(func(player): return player != id)
		update_players.rpc(GlobalCrap.players)

@rpc("authority", "call_local")
func update_players(new_players):
	print("update_players ", new_players)
	GlobalCrap.players = new_players

func _on_connected_ok():
	print("Connected ok")
	
func _on_connected_fail():
	print("Connected fail")
	
func _on_server_disconnected():
	print("Server disconnected")
	multiplayer.multiplayer_peer = null
	GlobalCrap.players = [1]
	get_tree().change_scene_to_file("start.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer.is_server():
		var time = str(Time.get_ticks_msec())
		#print("Send: ", time)
		update_game.rpc(time)

@rpc
func update_game(data):
	pass
	#print("Received: ", data)

# ?????????????????? Why da fok do i need this? This is needed to match with
# start.gd, do not touch.
@rpc("call_local")
func load_game():
	pass
