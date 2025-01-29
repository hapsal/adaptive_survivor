extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
var damage_popup = preload("res://scenes/damage_popup.tscn")
var enemy_speed = 80
var health = 3

signal enemy_dead2

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * enemy_speed
	move_and_slide()
	
	if velocity.length() > 0:
		%SnökEnemy.play("walk")

func take_damage():
	health -= 1
	
	var popup = damage_popup.instantiate()
	popup.text = str(1)
	get_tree().get_root().add_child(popup)
	popup.global_position = global_position + Vector2(-60, -25)
	
	# Animate the popup with scale and fade
	var popup_tween = create_tween()
	popup_tween.set_parallel(true)  # This allows multiple properties to animate simultaneously
	
	# Scale animation
	popup_tween.tween_property(popup, "scale", Vector2(2, 2), 0.2)
	popup_tween.chain().tween_property(popup, "scale", Vector2(1, 1), 0.2)
	
	# Fade animation
	popup_tween.tween_property(popup, "modulate:a", 1.0, 0.1)  # Start fully visible
	popup_tween.chain().tween_property(popup, "modulate:a", 0.0, 0.3)  # Fade out
	
	# Upward movement
	popup_tween.tween_property(popup, "position", 
		popup.position + Vector2(0, -30), 0.4)
	
	# Play hurt animation
	if health > 0:
		var hurt_tween = create_tween()
		hurt_tween.tween_property(%SnökEnemy, "modulate", Color(3, 0.25, 0.25), 0.2)
		hurt_tween.chain().tween_property(%SnökEnemy, "modulate", Color(1, 1, 1), 0.2)
	else:
		enemy_dead2.emit()
		await get_tree().create_timer(0.2).timeout
		popup.queue_free()
		queue_free()
		

func dmg_popup(amount):
	var popup = damage_popup.instantiate()
	popup.text = str(amount)
	popup.position = position + Vector2(-60, -25)
	get_tree().current_scene.add_child(popup)
