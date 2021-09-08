extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal change_done

onready var base = get_node("/root/base")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func on_scene_change():
	base._on_respawn_set(1)
	base.on_respawn(false)
	yield(base, "respawn_done")
	emit_signal("change_done")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
