extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Players: ", GlobalCrap.players)
	print("I am: ", multiplayer.get_unique_id())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass