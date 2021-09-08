extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var base = get_node("/root/base")
export var final = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_goal_body_entered(body):
	if body.is_in_group("player") && base.state == "play":
		if final || base.mode == "level":
			base._end()
			return
		base.next_level()
		
func _input(event):
	if event.is_action_pressed("test"):
		if final:
			base._end()
			return
		base.next_level()
