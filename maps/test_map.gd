extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		multiplayer.multiplayer_peer = null
		get_tree().change_scene_to_file("start.tscn")
	elif multiplayer.is_server() and Input.is_action_pressed("test_f1"):
		win_game.rpc()
	elif multiplayer.is_server() and Input.is_action_pressed("test_f2"):
		lose_game.rpc()

func _on_end_area_body_entered(body):
	print("End area collision")
	if multiplayer.is_server():
		win_game.rpc()

@rpc("call_local")
func win_game():
	$WinUi.show()
	if multiplayer.is_server():
		$WinUi/PlayAgainButton.show()

@rpc("call_local")
func lose_game():
	$LoseUi.show()
	if multiplayer.is_server():
		$LoseUi/TryAgainButton.show()

@rpc("call_local")
func restart_game():
	$WinUi.hide()
	$LoseUi.hide()
	if multiplayer.is_server():
		print("Reset position")
		$Bicycle.reset()

func _on_play_again_button_pressed():
	restart_game.rpc()

func _on_try_again_button_pressed():
	restart_game.rpc()

func _on_leave_button_pressed():
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("start.tscn")
