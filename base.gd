extends Node2D

var state = "play"
var respawn = 1
var level = 1
var mode ="play"

var timer:float = 0
var deaths = 0

var leveltime = [0.0, 0.0, 0.0, 0.0, 0.0]

signal start_respawn(id)
signal scene_changed
signal respawn_done

onready var anim = $anim
onready var music_anim = $music_anim
onready var menu = $menu/menu
onready var info = $menu/info
onready var end = $menu/end
onready var pause_screen = $menu/pause
onready var player = $player
# Called when the node enters the scene tree for the first time.
func _ready():
	state = "pause"
	respawn = 1
	menu.visible = true
	info.visible = false
	end.visible = false
	pause_screen.visible = false
	
func _play():
	mode = "play"
	anim.play("fade")
	yield(anim, "animation_finished")
	menu._hideall()
	timer = 0
	deaths = 0
	respawn = 1
	level = 1
	leveltime = [0.0, 0.0, 0.0, 0.0, 0.0]
	change_scene("res://levels/1.tscn", false)
	yield(self, "scene_changed")
	state = "play"
	anim.play_backwards("fade")
	yield(anim, "animation_finished")

	
func _resetlevel():
	state = "pause"
	anim.play("fade")
	yield(anim, "animation_finished")
	menu._hideall()
	respawn = 1
	leveltime[level-1] = 0
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
	player.state = "idle"
	
	if play:
		yield(anim, "animation_finished")
	propagate_call("check_respawn", [respawn])
	if play:
		anim.play_backwards("fade")
		yield(anim, "animation_finished")
		state = "play"
	yield(get_tree().create_timer(0.1), "timeout")
		
	emit_signal("respawn_done")
	
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
		
	for i in get_tree().get_nodes_in_group("room"):
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
		
	print("a1")
	emit_signal("scene_changed")
	
func _end():
	state = "pause"
	anim.play("fade")
	yield(anim, "animation_finished")
	end.visible = true
	menu.visible = false
	menu.end_text()
	end.get_node("back").grab_focus()
	#change_scene("res://levels/1.tscn", false)
	
	anim.play_backwards("fade")
	yield(anim, "animation_finished")
	level = 1
	respawn = 1
	state = "pause"
	
	
func _playlevel(num):
	leveltime = [0.0, 0.0, 0.0, 0.0, 0.0]
	mode = "level"
	anim.play("fade")
	yield(anim, "animation_finished")
	menu._hideall()
	timer = 0
	deaths = 0
	respawn = 1
	level = int(num)
	change_scene("res://levels/"+ str(num) + ".tscn", false)
	yield(self, "scene_changed")
	
	state = "play"
	anim.play_backwards("fade")
	yield(anim, "animation_finished")

	
	
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
	
	if mode == "level":
		pause_screen.get_node("restart2").disabled = true
	elif mode == "play":
		pause_screen.get_node("restart2").disabled = false
		
	pause_screen.get_node("continue").grab_focus()
	
	
func unpause():
	state = "play"
	pause_screen.visible = false
	

func _process(delta):
	if state == "play":
		timer += delta
		leveltime[level-1] += delta
		
func _notification(notification):
	if notification == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if state == "play":
			pausegame()
	
