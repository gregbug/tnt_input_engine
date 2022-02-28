extends KinematicBody2D

const SHIP_SIZE: Vector2 = (Vector2(32, 32) * 3 ) / 2
const SHIP_SPEED: int = 110
const SHIP_MAX_SPEED: int = 200

onready var ship: Sprite = $SpriteShip
onready var bullet: PackedScene = preload("res://demo/scenes/bullet.tscn")
onready var fire1: Position2D = $SpriteShip/fire1_pos
onready var fire2: Position2D = $SpriteShip/fire2_pos
onready var fire3: Position2D = $SpriteShip/fire3_pos

var screen_size: Vector2 = Vector2.ZERO
var ship_velocity: Vector2 = Vector2.ZERO
var ship_xy: Vector2 = Vector2.ZERO

func _ready() -> void:
	screen_size = get_viewport_rect().size
	position = screen_size / 2
	
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(TNTInputEngine.ACTION_JOY_A):
		fire1_shoot()
	elif Input.is_action_just_pressed(TNTInputEngine.ACTION_JOY_B):
		fire2_shoot()
		
	if Input.is_action_pressed("axis_leftx-") || Input.is_action_pressed("axis_leftx+") || Input.is_action_pressed("axis_lefty-") || Input.is_action_pressed("axis_lefty+"):
		ship_xy.x = Input.get_axis("axis_leftx-", "axis_leftx+")
		ship_xy.y = Input.get_axis("axis_lefty-", "axis_lefty+")
		# user move and rotate the ship with virtual touch joypad #############################
		ship_velocity = ship_xy * SHIP_MAX_SPEED
		# rotate ship
		ship.rotation = lerp_angle(ship.rotation, ship_velocity.angle(), .2)
		# move ship
		# warning-ignore:return_value_discarded
		move_and_slide(ship_velocity).normalized()
	else:
		## if no power decelerate ship motion....
		if (ship_velocity != Vector2.ZERO):
			if abs(ship_velocity.x) > 10 || abs(ship_velocity.y) > 10:
				# decelerate...
				ship_velocity.x = lerp(ship_velocity.x, 0.0, 0.01)
				ship_velocity.y = lerp(ship_velocity.y, 0.0, 0.01)
				# warning-ignore:return_value_discarded
				move_and_slide(ship_velocity).normalized()
			else:
				## ship is now stopped... engine off...
				ship_velocity = Vector2.ZERO

	position.x = wrapf(position.x, -SHIP_SIZE.x, screen_size.x + SHIP_SIZE.x)
	position.y = wrapf(position.y, -SHIP_SIZE.y, screen_size.y + SHIP_SIZE.y)

func fire1_shoot() -> void:
	var b1: Node2D = bullet.instance()
	get_node("/root").add_child(b1)
	b1.start(fire1.global_position, Vector2(1, 0).rotated(fire1.global_rotation))
	
func fire2_shoot() -> void:
	var b1: Node2D = bullet.instance()
	var b2: Node2D = bullet.instance()
	var b3: Node2D = bullet.instance()
	get_node("/root").add_child(b1)
	get_node("/root").add_child(b2)
	get_node("/root").add_child(b3)
	b1.start(fire1.global_position, Vector2(1, 0).rotated(fire1.global_rotation))
	b2.start(fire2.global_position, Vector2(1, 0).rotated(fire2.global_rotation))
	b3.start(fire3.global_position, Vector2(1, 0).rotated(fire3.global_rotation))


