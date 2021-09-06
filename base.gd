extends Node2D

var state = "play"
var respawn = 1
var level = 1

var timer:float = 0
var deaths = 0

signal start_respawn(id)

onready var anim = $anim
onready var music_anim = $music_anim
onready var menu = $menu/menu
onready var info = $menu/info
onready var end = $menu/end
onready var pause_screen = $menu/pause
# Called when the node enters the scene tree for the first time.
func _ready():
	state = "pause"
	respawn = 1
	menu.visible = true
	info.visible = false
	end.visible = false
	pause_screen.visible = false
	
func _play():
	anim.play("fade")
	yield(anim, "animation_finished")
	menu._hideall()
	timer = 0
	deaths = 0
	respawn = 1
	change_scene("res://levels/1.tscn", false)
	anim.play_backwards("fade")
	yield(anim, "animation_finished")
	state = "play"
	
func _resetlevel():
	anim.play("fade")
	yield(anim, "animation_finished")
	menu._hideall()
	respawn = 1
	on_respawn(false)
	anim.play_backwards("fade")
	yield(anim, "animation_finished")
	state = "play"
	

func _on_respawn_set(id):
	respawn = id

func on_respawn(play=true):
	if play:
		anim.play("fade")
		deaths += 1
	state = "pause"
	if play:
		yield(anim, "animation_finished")
	propagate_call("check_respawn", [respawn])
	if play:
		anim.play_backwards("fade")
		yield(anim, "animation_finished")
	state = "play"
	
func next_level():
	if state == "play":
		level += 1
		respawn = 1
		change_scene("res://levels/"+str(level)+".tscn")
	
func change_scene(path, play=true):
	state = "pause"
	if play:
		anim.play("fade")
		yield(anim, "animation_finished")
	for i in get_children():
		if i.is_in_group("room"):
			i.queue_free()
			
	var newroom = load(path).instance()
	call_deferred("add_child", newroom)
	newroom.call_deferred("on_scene_change")
	yield(newroom, "change_done")

	yield(get_tree().create_timer(0.4), "timeout")

	if play:
		state = "play"
		anim.play_backwards("fade")
		yield(anim, "animation_finished")

func _end():
	state = "pause"
	anim.play("fade")
	yield(anim, "animation_finished")
	end.visible = true
	menu.visible = false
	menu.end_text()
	end.get_node("back").grab_focus()
	change_scene("res://levels/1.tscn", false)
	anim.play_backwards("fade")
	yield(anim, "animation_finished")
	level = 1
	respawn = 1
	state = "pause"
	
func _input(event):
	if Input.is_action_just_pressed("pause") && state == "play":
		pausegame()
		
	elif Input.is_action_just_pressed("pause") && state == "pause" && !menu.visible:
		unpause()
		
func pausegame():
	state = "pause"
	menu.visible = false
	info.visible = false
	end.visible = false
	pause_screen.visible = true
	pause_screen.get_node("continue").grab_focus()
	
func unpause():
	state = "play"
	pause_screen.visible = false
	

func _process(delta):
	if state == "play":
		timer += delta
		
func _notification(notification):
	if notification == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if state == "play":
			pausegame()
