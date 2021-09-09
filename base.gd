extends Node2D

var state = "play"
var respawn = 1
var level = 1
var mode ="play"

var timer:float = 0
var deaths = 0

var leveltime = [0.0, 0.0, 0.0, 0.0, 0.0]
var mods = []

signal start_respawn(id)
signal scene_changed
signal respawn_done

signal set_respawn(id)
signal reset_level

signal play_all
signal play_level(num)

signal pause
signal unpause
# pause and unpause signals / change of state

var text = preload("res://level stuff/text.tscn")

onready var anim = $anim
onready var music_anim = $music_anim
onready var menu = $menu/menu
onready var info = $menu/info
onready var end = $menu/end
onready var pause_screen = $menu/pause
onready var player = $player
onready var modlist = $menu/menu/mods

# Called when the node enters the scene tree for the first time.
func _ready():
	state = "pause"

	var dir = Directory.new()
	
	mods = []
	dir.open("user://")
	if dir.dir_exists("user://mods"):
		dir.change_dir("user://mods")
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				if ProjectSettings.load_resource_pack("user://mods/" + file):
					mods.append(file.get_basename())
				
		dir.list_dir_end()
		
	for i in mods:
		add_child(load("res://"+i+".tscn").instance())
		modlist.bbcode_text += "\n"+i
	
	if modlist.bbcode_text == "mods:":
		modlist.bbcode_text = "no mods installed."
		
	respawn = 1
	menu.visible = true
	info.visible = false
	end.visible = false
	pause_screen.visible = false
		
				

	
func _play():
	mode = "play"
	anim.play("fade")
	yield(anim, "animation_finished")
	emit_signal("play_all")
	menu._hideall()
	leveltime = [0.0, 0.0, 0.0, 0.0, 0.0]
	change_scene("res://levels/1.tscn", false)
	yield(self, "scene_changed")
	timer = 0
	deaths = 0
	respawn = 1
	level = 1
	state = "play"
	anim.play_backwards("fade")
	yield(anim, "animation_finished")

	
func _resetlevel():
	state = "pause"
	anim.play("fade")
	yield(anim, "animation_finished")
	emit_signal("reset_level")
	menu._hideall()
	respawn = 1
	leveltime[level-1] = 0
	on_respawn(false)
	anim.play_backwards("fade")
	yield(anim, "animation_finished")
	state = "play"
	

func _on_respawn_set(id):
	emit_signal("set_respawn", id)
	respawn = id

func on_respawn(play=true):
	emit_signal("start_respawn", respawn)
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
	timer = 0.0
	mode = "level"
	anim.play("fade")
	yield(anim, "animation_finished")
	emit_signal("play_level")
	menu._hideall()
	level = int(num)
	change_scene("res://levels/"+ str(num) + ".tscn", false)
	yield(self, "scene_changed")
	timer = 0
	deaths = 0
	respawn = 1
	state = "play"
	anim.play_backwards("fade")
	yield(anim, "animation_finished")

	
	
func _input(event):
	if Input.is_action_just_pressed("pause") && state == "play":
		pausegame()
		
	elif Input.is_action_just_pressed("pause") && state == "pause" && (pause_screen.visible || menu.levelreset.visible || menu.gamereset.visible):
		unpause()
	
func pausegame():
	emit_signal("pause")
	state = "pause"
	menu._hideall()
	pause_screen.visible = true
	
	if mode == "level":
		pause_screen.get_node("restart2").disabled = true
	elif mode == "play":
		pause_screen.get_node("restart2").disabled = false
		
	pause_screen.get_node("continue").grab_focus()
	
	
func unpause():
	emit_signal("unpause")
	state = "play"
	menu._hideall()
	

func _process(delta):
	if state == "play":
		timer += delta
		leveltime[level-1] += delta
		
func _notification(notification):
	if notification == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if state == "play":
			pausegame()
	
