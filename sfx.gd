extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func click_button():
	$ClickButton.play()

func game_over():
	$GameOver.play()

func cheer():
	$Cheer.play()

func engine():
	$Engine.play()
