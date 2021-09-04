extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var particles = $Particles2D
onready var text = $text
# Called when the node enters the scene tree for the first time.
func _ready():
	_on_play_focus_exited()

func _on_play_focus_entered():
	particles.emitting = true
	text.modulate = "#FFCDB2"
	

func _on_play_focus_exited():
	particles.emitting = false
	text.modulate = "#e5989b"
