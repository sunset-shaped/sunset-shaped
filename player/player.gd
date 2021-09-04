extends KinematicBody2D


#establish scene name for saving
export var scene_id = "player"

#physics modes with numbers
var physics = {
	"air": {
		"speed": 500,
		"gravity": 2800,
		"friction": 0.4,
		"acceleration": 0.15,
		"jumpheight": 240,
		"jumpinc": 0.64,
		"jgravity": 300,
		"downgravity": 0,
	},
	"water":{
		"speed": 300,
		"gravity": 50,
		"friction": 0.2,
		"acceleration": 0.10,
		"jumpheight": 10,
		"jumpinc": 1,
		"jgravity": 100,
		"downgravity": 25
	}
}

onready var raycasts = {
	"floor":[$floor_raycast/floor, $floor_raycast/floor2, $floor_raycast/floor3],
	"left":[$left/floor, $left/floor2, $left/floor3],
	"right":[$right/floor, $right/floor2, $right/floor3]
	}

#player's current physics numbers
export (int) var speed = 800
export (int) var slidespeed = 2000
export (int) var gravity = 3000
export (int) var downgravity = 0

export (float, 0, 1.0) var friction = 0.4
export (float, 0, 1.0) var acceleration = 0.20
export (float, 0, 1.0) var slideacceleration = 0.05

export (float, 0, 1.0) var jumpheight = 250
export (float, 0, 1.0) var jumpinc = 0.79
export (float, 0, 1.0) var jgravity = 600

#setting up ground variables
var velocity = Vector2.ZERO
var curforce = jumpheight

var dialogue = false
var inwater = false

var giving = false

var playerpause = false
var curphy:String

var doublejump = false
var doubledash = false
var speedboost = false

var state = "idle"

onready var base = get_node("/root/base")

func _ready():
	#turn on things, set the base
	change_physics("air")
	$"collision".disabled = false
	

func get_input(delta):
	
	#if we don't want to take input, don't take input
		
	if base.state != "play":
		velocity.x = 0
		velocity.y = 0
		return
		
		
	#settle these variables first
	var onfloor = raycast("floor")
	var leftwall = raycast("left") && Input.is_action_pressed("left")
	var rightwall = raycast("right") && Input.is_action_pressed("right")
	
	
	#direction of player
	var dir = 0
	if Input.is_action_pressed("right"):
		dir += 1
	if Input.is_action_pressed("left"):
		dir -= 1
	
	#sideways speed, and/or friction
	if dir != 0:
		if state == "idle":
			state = "walk"
		velocity.x = lerp(velocity.x, dir * speed, acceleration * delta * 70)
	else:
		if state == "walk":
			state = "idle"
		velocity.x = lerp(velocity.x, 0, friction * delta * 70)

	#apply gravity when finished jumping
	if Input.is_action_just_released("jump"):	
		if state == "jumping":
			velocity.y += jgravity
			state = "falling"
			
		if onfloor:
			state = "idle"
			
	
	if Input.is_action_just_pressed("jump"):
		if (leftwall || rightwall) && !onfloor:
			curforce = jumpheight
			velocity.y = -curforce
			state = "jumping"
			
		if leftwall && !onfloor:
			velocity.x = velocity.x + 1000
			
		if rightwall && !onfloor:
			velocity.x = velocity.x - 1000

	if Input.is_action_pressed("jump"):
		if onfloor || rightwall || leftwall:
			state = "jumping"


		if state == "jumping":
			velocity.y = clamp(velocity.y - curforce, -1000, 10000000)
			curforce *= jumpinc
		
	
	#moving down in water
	
	#reseting values when hitting floor
	if onfloor:
		curforce = jumpheight
		
		

	if leftwall || rightwall:
		velocity.y = clamp(velocity.y + 1000 * delta, -1500, 350)
	else:
		velocity.y = clamp(velocity.y + gravity * delta, -1500, 1500)
	

func _physics_process(delta):
	get_input(delta)
	var snap = Vector2.DOWN if state != "jumping" else Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP )
	

func raycast(area):
	for i in raycasts[area]:
		if i.is_colliding():
			return true
	return false
	
	
func change_physics(new):
	curphy = new
	for i in physics[new].keys():
		set(i, physics[new][i])

	

func _on_canstand_body_entered(body):
	if body.is_in_group("water"):
		inwater = true
		change_physics("water")
		velocity.y /= 10
		if velocity.y < 100:
			velocity.y = 100


func _on_canstand_body_exited(body):
	if body.is_in_group("water"):
		inwater = false
		change_physics("air")
		curforce = jumpheight
		if Input.is_action_pressed("jump"):
			velocity.y = -curforce


func _on_area_body_entered(body):
	if body.is_in_group("die"):
		base.on_respawn()
