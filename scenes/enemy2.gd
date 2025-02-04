extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
var damage_popup = preload("res://scenes/damage_popup.tscn")

var enemy_speed = 80
var health = 6

signal enemy_dead(position: Vector2)

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * enemy_speed
	move_and_slide()
	
	if velocity.length() > 0:
		%SnökEnemy.play("walk")

func take_damage(damage_amount):
	health -= damage_amount
	
	var popup = damage_popup.instantiate()
	popup.text = str(damage_amount)
	get_tree().get_root().add_child(popup)
	popup.global_position = global_position + Vector2(-60, -25)
	
	var popup_tween = create_tween()
	popup_tween.set_parallel(true)

	popup_tween.tween_property(popup, "scale", Vector2(2, 2), 0.2)
	popup_tween.chain().tween_property(popup, "scale", Vector2(1, 1), 0.2)
	
	popup_tween.tween_property(popup, "modulate:a", 1.0, 0.1)
	popup_tween.chain().tween_property(popup, "modulate:a", 0.0, 0.3)
	
	popup_tween.tween_property(popup, "position", 
		popup.position + Vector2(0, -30), 0.4)
	
	if health > 0:
		var hurt_tween = create_tween()
		hurt_tween.tween_property(%SnökEnemy, "modulate", Color(3, 0.25, 0.25), 0.2)
		hurt_tween.chain().tween_property(%SnökEnemy, "modulate", Color(1, 1, 1), 0.2)
	else:
		enemy_dead.emit(global_position)
		await get_tree().create_timer(0.2).timeout
		popup.queue_free()
		queue_free()
