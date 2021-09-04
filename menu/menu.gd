extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var info = get_parent().get_node("info")
onready var end = get_parent().get_node("end")
onready var base = get_node("/root/base")
onready var click = get_parent().get_node("clicksound")
# Called when the node enters the scene tree for the first time.
func _ready():
	$play.grab_focus()
	visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_play_pressed():
	click.play()
	base._play()


func _on_info_pressed():
	click.play()
	visible = false
	info.visible = true
	info.get_node("back").grab_focus()


func _on_back_pressed():
	click.play()
	info.visible = false
	end.visible = false
	visible = true
	$info.grab_focus()


func _on_quit_pressed():
	click.play()
	base.anim.play("fade")
	base.music_anim.play("fade")
	yield(base.anim, "animation_finished")
	get_tree().quit()


