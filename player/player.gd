extends KinematicBody2D


#establish scene name for saving
export var scene_id = "player"

onready var raycasts = {
	"floor":[$floor_raycast/floor, $floor_raycast/floor2, $floor_raycast/floor3],
	"left":[$left/floor, $left/floor2, $left/floor3],
	"right":[$right/floor, $right/floor2, $right/floor3]
	}

#constants and stuff / physics
export (int) var speed = 500
export (int) var gravity = 2800

export (float, 0, 1.0) var friction = 0.4
export (float, 0, 1.0) var acceleration = 0.15

export (float, 0, 1.0) var jumpheight = 240
export (float, 0, 1.0) var jumpinc = 0.64
export (float, 0, 1.0) var jgravity = 300

#setting up ground variables
var velocity = Vector2.ZERO
var curforce = jumpheight

var dialogue = false

var state = "idle"
var touching = false

onready var base = get_node("/root/base")
onready var walkparticles = $Particles2D
onready var jumpsound = $AudioStreamPlayer
onready var diesound = $AudioStreamPlayer2

onready var debug = $Label

signal jump(loc)
signal change_state(state)
signal touch


var lastonfloor = 0.0
var lastonleft = 0.0
var lastonright = 0.0

export (float) var coyote_time = 0.2


func _ready():
	#turn on things, set the base
	pass
	

func get_input(delta):
	
	#if we don't want to take input, don't take input
	if base.state != "play":
		velocity.x = 0
		velocity.y = 0
		return
		
		
	#settle these variables first
	var onfloor = raycast("floor")
	var leftwall = raycast("left")
	var rightwall = raycast("right")
	
	lastonfloor += delta
	lastonleft += delta
	lastonright += delta
	
	if onfloor:
		lastonfloor = 0
	if leftwall:
		lastonleft = 0
	if rightwall:
		lastonright = 0
		
	onfloor = lastonfloor < coyote_time
	leftwall = lastonleft < coyote_time
	rightwall = lastonright < coyote_time
	
	if (onfloor || leftwall || rightwall) && !touching:
		touching = true
		emit_signal("touch")
		jumpsound.play()
		
	if !onfloor && !leftwall && !rightwall:
		touching = false
	
	
	#direction of player
	var dir = 0
	if Input.is_action_pressed("right"):
		dir += 1
	if Input.is_action_pressed("left"):
		dir -= 1
	
	#sideways speed, and/or friction
	if dir != 0:
		if state == "idle":
			set_state("walk")
		velocity.x = lerp(velocity.x, dir * speed, acceleration * delta * 70)
	else:
		if state == "walk":
			set_state("idle")
		velocity.x = lerp(velocity.x, 0, friction * delta * 70)

	#apply gravity when finished jumping
	if Input.is_action_just_released("jump"):	
		if state == "jumping":
			velocity.y += jgravity
			set_state("falling")
			
		if onfloor:
			set_state("idle")
			
	
	if Input.is_action_just_pressed("jump"):
		if (leftwall || rightwall) && !onfloor && state != "jumping":
			curforce = jumpheight
			velocity.y = -curforce
			set_state("jumping")
			
			lastonleft = 2000
			lastonright = 2000
			
			if leftwall:
				emit_signal("jump", "left")
			elif rightwall:
				emit_signal("jump", "right")
		
		if onfloor && state != "jumping":
			
			onfloor = 2000
			
			curforce = jumpheight
			velocity.y = -curforce
			
			emit_signal("jump", "floor")
			set_state("jumping")
			
		if leftwall && !onfloor:
			velocity.x = velocity.x + 1000
			
		if rightwall && !onfloor:
			velocity.x = velocity.x - 1000
			

	if Input.is_action_pressed("jump"):
		if onfloor || rightwall || leftwall:
			set_state("jumping")

		if state == "jumping":
			print("?")
			velocity.y = clamp(velocity.y - curforce, -1000, 10000000)
			curforce *= jumpinc
			
			lastonleft = 2000
			lastonright = 2000
			lastonfloor = 2000
		
#		if velocity.y >= 0:
#			set_state("falling")
		
	
	#moving down in water
	
	#reseting values when hitting floor
	if raycast("floor"):
		curforce = jumpheight
		lastonfloor = 0

	if (leftwall || rightwall) && state != "jumping":
		velocity.y = clamp(velocity.y + 1000 * delta, -1000, 350)
	else:
		velocity.y = clamp(velocity.y + gravity * delta, -1000, 1000)
	
	debug.text = str(state)

func _physics_process(delta):
	get_input(delta)
	var snap = Vector2.DOWN if state != "jumping" else Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP )
	

func raycast(area):
	for i in raycasts[area]:
		if i.is_colliding():
			return true
	return false
	

func _on_area_body_entered(body):
	if body.is_in_group("die"):
		diesound.play()
		base.on_respawn()

func set_state(new):
	if state != new:
		emit_signal("change_state", new)
	state = new
	
