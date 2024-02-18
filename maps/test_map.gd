extends Node3D

var start_time = 0
var end_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		restart_game.rpc(Time.get_unix_time_from_system())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer.is_server():
		sync_start_time.rpc(start_time)
	
	if Input.is_action_pressed("ui_cancel"):
		multiplayer.multiplayer_peer = null
		get_tree().change_scene_to_file("start.tscn")
	elif multiplayer.is_server() and Input.is_action_pressed("test_f1"):
		win_game.rpc(Time.get_unix_time_from_system())
	elif multiplayer.is_server() and Input.is_action_pressed("test_f2"):
		lose_game.rpc(Time.get_unix_time_from_system())
		
	if $WinUi.is_visible() or $LoseUi.is_visible():
		$Hud/TimeText.text = format_time(end_time - start_time)
	else:
		$Hud/TimeText.text = format_time(Time.get_unix_time_from_system() - start_time)

	$Hud/SpeedText.text = str(int($Bicycle.current_velocity))

func format_time(time):
	var minutes = int(time / 60)
	var seconds = int(time - (minutes * 60))
	var milliseconds = int( (time - (minutes * 60) - seconds) * 1000)
	var display = "%02d" % minutes + ":" + "%02d" % seconds + ":" + "%03d" % milliseconds
	return display

@rpc
func sync_start_time(time):
	start_time = time

func _on_end_area_body_entered(body):
	print("End area collision")
	if multiplayer.is_server():
		win_game.rpc(Time.get_unix_time_from_system())

@rpc("call_local")
func win_game(time):
	end_time = time
	$WinUi.show()
	if multiplayer.is_server():
		$EndArea/EndCollision.set_deferred("disabled", true)
		$WinUi/PlayAgainButton.show()
		

@rpc("call_local")
func lose_game(time):
	end_time = time
	$LoseUi.show()
	if multiplayer.is_server():
		$EndArea/EndCollision.set_deferred("disabled", true)
		$LoseUi/TryAgainButton.show()

@rpc("call_local")
func restart_game(time):
	start_time = time
	$WinUi.hide()
	$LoseUi.hide()
	if multiplayer.is_server():
		print("Reset position")
		$EndArea/EndCollision.set_deferred("disabled", false)
		$Bicycle.reset()

func _on_play_again_button_pressed():
	restart_game.rpc(Time.get_unix_time_from_system())

func _on_try_again_button_pressed():
	restart_game.rpc(Time.get_unix_time_from_system())

func _on_leave_button_pressed():
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("start.tscn")