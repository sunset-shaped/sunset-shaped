extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var info = get_parent().get_node("info")
onready var end = get_parent().get_node("end")
onready var base = get_node("/root/base")
onready var click = get_parent().get_node("clicksound")
onready var endtext = get_parent().get_node("end/text")
onready var pause = get_parent().get_node("pause")
onready var levelreset = get_parent().get_node("levelconfirm")
onready var gamereset = get_parent().get_node("gameconfirm")
# Called when the node enters the scene tree for the first time.
func _ready():
	$play.grab_focus()
	visible = true
	info.visible = false
	end.visible = false
	pause.visible = false
	levelreset.visible = false
	gamereset.visible = false

func end_text():
	var taken = stepify(base.timer, 0.01)
	
	var hr = floor(taken/3600)
	var mn = floor(taken/60) - (hr * 60)
	var sc = floor(taken) - (mn*60) - (hr*3600)
	var mls = fmod(taken,1) * 100
	
	var deaths = base.deaths
	
	if hr == 0:
	
		endtext.bbcode_text = """[center]thank you for playing [color=#FFB4A2]sunset-shaped[/color] by [color=#FFB4A2]bucketfish[/color].

time - %s:%s.%s
deaths - %s
[color=#FFB4A2]stay safe.[/color]""" % [str(mn), str(sc), str(mls), str(deaths)]

	else:
		endtext.bbcode_text = """[center]thank you for playing [color=#FFB4A2]sunset-shaped[/color] by [color=#FFB4A2]bucketfish[/color].

time - $s:%s:%s.%s
deaths - %s
[color=#FFB4A2]stay safe.[/color]""" % [str(hr), str(mn), str(sc), str(mls), str(deaths)]


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




func _on_continue_pressed():
	click.play()
	base.unpause()
	


func _on_quittomenu_pressed():
	click.play()
	base.anim.play("fade")
	yield(base.anim, "animation_finished")
	pause.visible = false
	_ready()
	base.anim.play_backwards("fade")


func _on_levelreset_pressed():
	click.play()
	pause.visible = false
	levelreset.visible = true
	levelreset.get_node("continue").grab_focus()


func _on_levelconfirm_pressed():
	click.play()
	base._resetlevel()


func _on_backtopause_pressed():
	click.play()
	levelreset.visible = false
	gamereset.visible = false
	pause.visible = true
	pause.get_node("continue").grab_focus()
	


func _on_gamereset_pressed():
	click.play()
	pause.visible = false
	gamereset.visible = true
	gamereset.get_node("continue").grab_focus()


func _on_gameconfirm_pressed():
	click.play()
	base._play()

func _hideall():
	visible = false
	info.visible = false
	end.visible = false
	pause.visible = false
	levelreset.visible = false
	gamereset.visible = false
