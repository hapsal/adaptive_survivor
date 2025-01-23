extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
var enemy_speed = 100
var health = 3

signal enemy_dead

func _ready():
	#Play walk animation
	pass

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * enemy_speed
	move_and_slide()
	
	if velocity.length() > 0:
		%SnökEnemy.play("walk")

func take_damage():
	health -= 1
	# Play animation when hurt
	
	if health == 0:
		queue_free()
		enemy_dead.emit()
		# Play animation when enemy dead
