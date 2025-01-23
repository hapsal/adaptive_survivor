extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
var damage_popup = preload("res://scenes/damage_popup.tscn")
var enemy_speed = 50
var health = 30

signal enemy_dead3

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * enemy_speed
	move_and_slide()
	
	if velocity.length() > 0:
		%SnökEnemyElite.play("walk")

func take_damage():
	health -= 1
	# Play animation when hurt
	
	dmg_popup(1)
	
	if health == 0:
		queue_free()
		enemy_dead3.emit()
		# Play animation when enemy dead

func dmg_popup(amount):
	var popup = damage_popup.instantiate()
	popup.text = str(amount)
	popup.position = position + Vector2(-60, -25)
	get_tree().current_scene.add_child(popup)
