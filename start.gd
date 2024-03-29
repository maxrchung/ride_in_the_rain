extends Node

# Load file early so there is no lag when hitting start game 
var track = preload("res://maps/track_02_baked.tscn")

const PORT = 7069
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 64

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(address = ""):
	print("Join game")
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	GlobalCrap.players = [1]
	
func create_game():
	print("Create game")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	update_players([1])
	$CreateButton.hide()
	$IpInput.hide()
	$JoinButton.hide()
	$InstructionsButton.hide()
	$TitleSplash.hide()
	$WaitingText.show()
	$StartButton.show()
	$LeaveButton.show()
	$PlayersCount.show()

# Server manages and tells everyone about player updates
@rpc("authority", "call_local")
func update_players(new_players):
	print("update_players ", new_players)
	GlobalCrap.players = new_players
	var list = []
	for i in range(GlobalCrap.players.size()):
		var player = GlobalCrap.players[i]
		var key = i + 1
		if multiplayer.get_unique_id() == player:
			list.push_back(str(key) + " (You)")
		else:
			list.push_back(str(key))
	$PlayersCount.text = "\n".join(list)

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
	
func _on_connected_ok():
	print("Connected ok")
	$IpInput.hide()
	$JoinButton.hide()
	$CreateButton.hide()
	$InstructionsButton.hide()
	$TitleSplash.hide()	
	$WaitingText.show()
	$LeaveButton.show()
	$PlayersCount.show()
	
func _on_connected_fail():
	print("Connected fail")
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected():
	print("Server disconnected")
	multiplayer.multiplayer_peer = null
	GlobalCrap.players = [1]
	$IpInput.show()
	$JoinButton.show()
	$CreateButton.show()
	$InstructionsButton.show()
	$TitleSplash.show()	
	$WaitingText.hide()
	$LeaveButton.hide()
	$StartButton.hide()
	$PlayersCount.hide()

func _on_create_button_pressed():
	Sfx.click_button()
	create_game()

func _on_join_button_pressed():
	Sfx.click_button()
	join_game($IpInput.text)

@rpc("call_local")
func load_game():
	get_tree().change_scene_to_file("game.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_button_pressed():
	Sfx.click_button()
	load_game.rpc()

func _on_leave_button_pressed():
	Sfx.click_button()
	multiplayer.multiplayer_peer = null
	GlobalCrap.players = [1]
	$IpInput.show()
	$JoinButton.show()
	$CreateButton.show()
	$InstructionsButton.show()
	$TitleSplash.show()
	$WaitingText.hide()
	$LeaveButton.hide()
	$StartButton.hide()
	$PlayersCount.hide()

@rpc
func update_game(data):
	get_tree().change_scene_to_file("game.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_instructions_button_pressed():
	Sfx.click_button()
	get_tree().change_scene_to_file("instructions.tscn")
