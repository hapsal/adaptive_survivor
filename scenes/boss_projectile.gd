extends Area2D

@export var speed: float = 150.0
@export var damage: int = 40
var direction: Vector2 = Vector2.ZERO

var noise = FastNoiseLite.new()
var time: float = 0.0
var noise_offset: float = 0.0
var current_speed: float
var base_speed: float

func _ready():
	rotation = direction.angle() - PI/2
	noise.seed = randi()
	noise.frequency = 0.3
	time = randf() * TAU
	base_speed = speed
	current_speed = speed

func _physics_process(delta):
	time += delta
	noise_offset += delta
	
	var sine_multiplier = 0.85 + sin(time * 2.0) * 0.15
	var noise_multiplier = remap(noise.get_noise_1d(noise_offset), -1.0, 1.0, 0.9, 1.1)
	var speed_multiplier = sine_multiplier * noise_multiplier
	
	current_speed = lerp(current_speed, base_speed * speed_multiplier, 0.2)
	position += direction * current_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
