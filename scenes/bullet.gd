extends Area2D

var bullet_distance = 0
var damage = 1
const BASE_DAMAGE: float = 1.0
const DAMAGE_SCALE_FACTOR: float = 2

@onready var player = get_node("/root/Game/Player")

func _ready() -> void:
	update_damage()

func _physics_process(delta: float) -> void:
	const BULLET_SPEED = 150
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * BULLET_SPEED * delta

	bullet_distance += BULLET_SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body.is_in_group("enemy"):
		body.take_damage(damage)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func update_damage() -> void:
	damage = BASE_DAMAGE + (DAMAGE_SCALE_FACTOR * (player.level - 1))
