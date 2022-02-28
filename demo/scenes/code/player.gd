extends KinematicBody2D

onready var player_anim: AnimatedSprite = $Animation

const PLAYER_SIZE: Vector2 = Vector2(60, 80) / 2
const PLAYER_SPEED: int = 110

var screen_size: Vector2 = Vector2.ZERO
var player_velocity: Vector2 = Vector2.ZERO
var player_xy: Vector2 = Vector2.ZERO

func _ready() -> void:
	screen_size = get_viewport_rect().size
	position = screen_size / 2
	player_xy = Vector2.ZERO
		
func _physics_process(_delta: float) -> void:	
	if  Input.is_action_pressed(TNTInputEngine.ACTION_JOY_LEFT): 
			player_anim.flip_h = true
			player_anim.play("right")
			player_xy.x = -1
	elif Input.is_action_pressed(TNTInputEngine.ACTION_JOY_RIGHT):
			player_anim.flip_h = false
			player_anim.play("right")
			player_xy.x = 1
	elif Input.is_action_just_released(TNTInputEngine.ACTION_JOY_LEFT) || Input.is_action_just_released(TNTInputEngine.ACTION_JOY_RIGHT):
			player_xy.x = 0
			player_anim.stop()
			player_anim.frame = 1

	if Input.is_action_pressed(TNTInputEngine.ACTION_JOY_UP):
			player_xy.y = -1
			if player_xy.x == 0: 
				player_anim.play("up")
	elif Input.is_action_pressed(TNTInputEngine.ACTION_JOY_DOWN):
			player_xy.y = 1
			if player_xy.x == 0:
				player_anim.play("down")
	elif Input.is_action_just_released(TNTInputEngine.ACTION_JOY_UP) || Input.is_action_just_released(TNTInputEngine.ACTION_JOY_DOWN):
			player_xy.y = 0
			player_anim.stop()
			player_anim.frame = 1
		
	if (player_xy.x != 0) || (player_xy.y != 0):
		player_velocity = (Vector2(player_xy.x, player_xy.y).normalized() * PLAYER_SPEED)	
		position.x = wrapf(position.x, -PLAYER_SIZE.x, screen_size.x + PLAYER_SIZE.x)
		position.y = wrapf(position.y, -PLAYER_SIZE.y, screen_size.y + PLAYER_SIZE.y)
		# warning-ignore:return_value_discarded
		move_and_slide(player_velocity)

