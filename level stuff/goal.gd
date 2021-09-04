extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var base = get_node("/root/base")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_goal_body_entered(body):
	base.next_level()
