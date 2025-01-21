extends Area2D

var bullet_distance = 0

func _physics_process(delta: float) -> void:
	const BULLET_SPEED = 1000
	const BULLET_RANGE = 1200
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * BULLET_SPEED * delta
	
	bullet_distance += BULLET_SPEED * delta
	if bullet_distance > BULLET_RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
