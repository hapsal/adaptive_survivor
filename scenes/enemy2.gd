extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
var damage_popup = preload("res://scenes/damage_popup.tscn")
var enemy_speed = 80
var health = 3

signal enemy_dead

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * enemy_speed
	move_and_slide()
	
	if velocity.length() > 0:
		%SnökEnemy.play("walk")

func take_damage():
	health -= 1
	# Play animation when hurt
	
	var tween = get_tree().create_tween()
	tween.tween_property(%SnökEnemy, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property(%SnökEnemy, "modulate", Color(1, 1, 1), 0.2)
	
	dmg_popup(1)
	
	if health == 0:
		queue_free()
		enemy_dead.emit()
		# Play animation when enemy dead

func dmg_popup(amount):
	var popup = damage_popup.instantiate()
	popup.text = str(amount)
	popup.position = position + Vector2(-60, -25)
	get_tree().current_scene.add_child(popup)
