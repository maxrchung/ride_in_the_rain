extends Node

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 64

var players = {}
var players_loaded = 0

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
func create_game():
	print("Game created")
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	players[1] = null
	player_connected.emit(1)
	
func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	
	
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)
	
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0
			
func _on_player_connected(id):
	print("Player ", id, " connected")
	_register_player.rpc_id(id)
	
@rpc("any_peer")
func _register_player():
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = null
	player_connected.emit(new_player_id)
	
func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)
	
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = null
	player_connected.emit(peer_id)
	
func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()


func _on_create_button_pressed():
	create_game()


func _on_join_button_pressed():
	print("Join text", $IpInput.text)
	join_game()
