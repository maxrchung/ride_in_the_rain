extends Node3D

var start_time = 0
var end_time = 0

const tex_three = preload("res://assets/text/three.png")
const tex_two = preload("res://assets/text/two.png")
const tex_one = preload("res://assets/text/one.png")
const tex_go = preload("res://assets/text/go_weeb.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	var win = get_window()
	if multiplayer.is_server():
		restart_game.rpc(Time.get_unix_time_from_system())

func is_in_ending():
	return $FinishTimer.time_left > 0 or $WinUi.visible or $LoseUi.visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $StartTimer.time_left > 0:
		var seconds = int($StartTimer.time_left)
		$Hud/PopupInfo.set_texture([tex_go, tex_one, tex_two, tex_three][seconds])
	else:
		# LMAOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO fk
		$Bicycle.should_reset = false
		
	if multiplayer.is_server():
		sync_start_time.rpc(start_time)
	
	if Input.is_action_pressed("ui_cancel"):
		multiplayer.multiplayer_peer = null
		get_tree().change_scene_to_file("start.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif multiplayer.is_server() and Input.is_action_pressed("test_f1"):
		win_game.rpc(Time.get_unix_time_from_system())
	elif multiplayer.is_server() and Input.is_action_pressed("test_f2"):
		lose_game.rpc()
		
	if $StartTimer.time_left > 0:
		$Hud/TimeText.text = format_time(0)
	elif end_time > start_time:
		$Hud/TimeText.text = format_time(end_time - start_time)
	else:
		$Hud/TimeText.text = format_time(Time.get_unix_time_from_system() - start_time)

	$Hud/SpeedText.text = str(int($Bicycle.speed))
	var speed_abs = $Bicycle.speed / 30
	$Hud/SpeedometerBg/SpeedometerArm.rotation_degrees = (speed_abs * (162)) - 87 

func format_time(time):
	var minutes = int(time / 60)
	var seconds = int(time - (minutes * 60))
	var milliseconds = int( (time - (minutes * 60) - seconds) * 1000)
	var display = "%02d" % minutes + "'" + "%02d" % seconds + "\"" + "%03d" % milliseconds
	return display

@rpc
func sync_start_time(time):
	start_time = time

func _on_end_area_body_entered(body):
	print("End area collision")
	if multiplayer.is_server():
		if !is_in_ending():
			win_game.rpc(Time.get_unix_time_from_system())
		
@rpc("call_local")
func win_game(time):
	Sfx.cheer()
	$Bicycle.crash()
	$FinishTimer.start(3.999)
	$Hud/FinishLabel.show()
	end_time = time
	if multiplayer.is_server():
		$EndArea/EndCollision.set_deferred("disabled", true)
		$WinUi/PlayAgainButton.show()
		
@rpc("call_local")
func lose_game():
	Sfx.game_over()
	$Bicycle.crash()
	$LoseUi.show()
	if multiplayer.is_server():
		$EndArea/EndCollision.set_deferred("disabled", true)
		$LoseUi/TryAgainButton.show()

@rpc("call_local")
func restart_game(time):
	Sfx.engine()
	$StartTimer.start(3.999)
	$Hud/PopupInfo.show()
	$WinUi.hide()
	$LoseUi.hide()
	if multiplayer.is_server():
		print("Reset position")
		$EndArea/EndCollision.set_deferred("disabled", false)
		$Bicycle.reset()

func _on_play_again_button_pressed():
	Sfx.click_button()
	restart_game.rpc(Time.get_unix_time_from_system())

func _on_try_again_button_pressed():
	Sfx.click_button()
	restart_game.rpc(Time.get_unix_time_from_system())

func _on_leave_button_pressed():
	Sfx.click_button()
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("start.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_timer_timeout():
	if multiplayer.is_server():
		start_time = Time.get_unix_time_from_system()
	$Hud/PopupInfo.hide()
	$Bicycle.should_reset = false
	

func _on_finish_timer_timeout():
	$Hud/FinishLabel.hide()
	$WinUi.show()

func _on_track_dev_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if multiplayer.is_server():
		if !is_in_ending():
			print("CrashTime")
			$Bicycle.crash()
			lose_game.rpc()


func _on_track_02_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if multiplayer.is_server():
		if !is_in_ending():
			print("CrashTime")
			$Bicycle.crash()
			lose_game.rpc()


func _on_end_area_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print("End area collision")
	if multiplayer.is_server():
		if !is_in_ending():
			win_game.rpc(Time.get_unix_time_from_system())
