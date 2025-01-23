extends CharacterBody2D

signal health_depleted

const PLAYER_SPEED = 200
var health = 100.0
var damage_rate = 10.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * PLAYER_SPEED
	move_and_collide(velocity * delta)
	
	if velocity.length() > 0.0:
		%KittyAnimation.play("walk")
	else:
		%KittyAnimation.play("idle")
	
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	
	if overlapping_mobs.size() > 0:
		health -= damage_rate * overlapping_mobs.size() * delta
		%HealthBar.value = health
		
		if health <= 0.0:
			health_depleted.emit()
			

func _on_game_level_up() -> void:
	health += 5.0
	damage_rate += 0.5
