extends Area2D

@export var speed: float = 70.0
@export var damage: int = 10
var direction: Vector2 = Vector2.ZERO

func _ready():	
	rotation = direction.angle() - PI/2
	

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
