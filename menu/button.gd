extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal levelselect(level)

onready var particles = $Particles2D
onready var text = $text

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_play_focus_exited()

func _on_play_focus_entered():
	particles.emitting = true
	if !disabled:
		text.modulate = "#FFCDB2"
	

func _on_play_focus_exited():
	particles.emitting = false
	if !disabled:
		text.modulate = "#e5989b"

func _levelselect_clicked():
	emit_signal("levelselect", name)
	
func _set(property, value):
	if property == "disabled":
		if value == true:
			text.modulate = "#b89c9d"
		elif value == false:
			text.modulate = "#e5989b"


func _on_pressed():
	release_focus()
