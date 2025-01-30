extends Area2D

@export var rotation_speed: float = 5.0
@export var target_detection_radius: float = 150.0

var current_target: Node2D = null
var target_position: Vector2 = Vector2.ZERO

var base_shoot_time: float = 2.0
var min_shoot_time: float = 0.1  # Minimum time between shots
var shoot_time_reduction: float = 0.1  # Reduce by 0.1 seconds per level

func _ready() -> void:
	var game = get_node("/root/Game")
	game.level_up.connect(_on_game_level_up)
	%ShootTimer.wait_time = base_shoot_time

func _physics_process(delta: float) -> void:
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.is_empty():
		current_target = null
		return
		
	current_target = get_best_target(enemies_in_range)
	
	if current_target and is_instance_valid(current_target):
		target_position = current_target.global_position
		
		var desired_angle = global_position.direction_to(target_position).angle()
		
		var angle_diff = wrapf(desired_angle - global_rotation, -PI, PI)
		if abs(angle_diff) > 0.01:
			global_rotation = lerp_angle(global_rotation, desired_angle, rotation_speed * delta)

func get_best_target(enemies: Array) -> Node2D:
	var best_target = null
	var closest_distance = INF
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
			
		var distance = global_position.distance_to(enemy.global_position)
		
		if distance <= target_detection_radius:
			if distance < closest_distance:
				closest_distance = distance
				best_target = enemy
	
	return best_target

# Visualize the detection radius
#func _draw() -> void:
	#draw_arc(Vector2.ZERO, target_detection_radius, 0, TAU, 32, Color(1, 0, 0, 0.2))

func shoot():
	const BULLET = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_bullet)

func _on_timer_timeout() -> void:
	shoot()
	
func _on_game_level_up() -> void:
	var new_shoot_time = base_shoot_time - shoot_time_reduction
	
	new_shoot_time = maxf(new_shoot_time, min_shoot_time)
	
	%ShootTimer.wait_time = new_shoot_time
	%ShootTimer.start()
