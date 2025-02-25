extends CharacterBody2D

signal health_depleted

const BASE_SPEED: float = 100.0
const BASE_HEALTH: float = 100.0
const BASE_DAMAGE_RATE: float = 15.0
const MAX_LEVEL: int = 99

var current_speed: float = BASE_SPEED
var current_health: float = BASE_HEALTH
var max_health: float = BASE_HEALTH
var damage_rate: float = BASE_DAMAGE_RATE
var level: int = 1

const HEALTH_SCALE_FACTOR: float = 1.15
const DAMAGE_RESISTANCE_FACTOR: float = 0.98
const SPEED_SCALE_FACTOR: float = 1.02

@export var xp_attraction_radius: float = 50.0

func _ready() -> void:
	%HealthBar.max_value = max_health
	%HealthBar.value = current_health
	add_to_group("player")
	
	var attraction_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	
	circle_shape.radius = xp_attraction_radius
	collision_shape.shape = circle_shape
	
	attraction_area.add_child(collision_shape)
	add_child(attraction_area)
	
	attraction_area.area_entered.connect(_on_xp_entered_attraction_range)

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_damage(delta)

func handle_movement(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * current_speed
	move_and_collide(velocity * delta)
	
	if velocity.length() > 0.0:
		%KittyAnimation.play("walk")
	else:
		%KittyAnimation.play("idle")

func handle_damage(delta: float) -> void:
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	
	Wwise.set_rtpc_value("PlayerHealth", current_health, null)
	
	if overlapping_mobs.size() > 0:
		var damage_multiplier = pow(DAMAGE_RESISTANCE_FACTOR, level - 1)
		var total_damage = damage_rate * overlapping_mobs.size() * delta * damage_multiplier
		
		current_health -= total_damage
		%HealthBar.value = current_health
		
		if current_health <= 0.0:
			health_depleted.emit()

func take_damage(damage_amount: float) -> void:
	var damage_multiplier = pow(DAMAGE_RESISTANCE_FACTOR, level - 1)
	var final_damage = damage_amount * damage_multiplier 
	
	current_health -= final_damage
	%HealthBar.value = current_health
	
	if current_health <= 0.0:
		Wwise.set_state("PlayerHealth", "Defeated")
		health_depleted.emit()

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	%HealthBar.value = current_health

func _on_game_level_up() -> void:
	level = min(level + 1, MAX_LEVEL)
	
	var old_health_percent = current_health / max_health
	max_health = BASE_HEALTH * pow(HEALTH_SCALE_FACTOR, level - 1)
	current_health = max_health * old_health_percent
	
	var heal_amount = max_health * 0.2
	current_health = min(current_health + heal_amount, max_health)
	
	%HealthBar.max_value = max_health
	%HealthBar.value = current_health
	
	current_speed = BASE_SPEED * pow(SPEED_SCALE_FACTOR, level - 1)
	
	display_level_up_effects()

func display_level_up_effects() -> void:
	# Add visual/audio feedback for level up
	# This is where you'd add particles, sounds, etc.
	pass


func _on_xp_entered_attraction_range(area: Area2D) -> void:
	if area.has_method("start_moving_to_player"):
		area.start_moving_to_player(self)
