extends Node2D

var state = "play"

var respawn = 0

var level = 1

signal start_respawn(id)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_respawn_set(id):
	respawn = id

func on_respawn():
	propagate_call("check_respawn", [respawn])
	
func next_level():
	level += 1
