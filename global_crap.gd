extends Node

# This is a list of unique IDs assigned by Godot's peer management.
# I am using a singleton because it is shared across Start asnd Game
# scenes. Order is determined by when the peer joined, last means
# later. You can check your own ID by using multiplayer.get_unique_id()
var players = []
