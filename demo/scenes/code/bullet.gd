extends Node2D

export (int) var speed: int = 300

var velocity: Vector2 = Vector2.ZERO

func start(_position: Vector2, _direction: Vector2) -> void:
	position = _position
	rotation = _direction.angle()
	velocity = _direction * speed

func _process(delta: float) -> void:
	position += velocity * delta

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
