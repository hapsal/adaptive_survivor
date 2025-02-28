extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
var damage_popup = preload("res://scenes/damage_popup.tscn")
var projectile = preload("res://scenes/boss_projectile.tscn")
@onready var health_label = %HealthLabel

var rng = RandomNumberGenerator.new()

var health = 10
var max_health = 10
var enemy_speed = 10

@export var attack_range: float = 250.0
var can_attack: bool = true
var current_phase = 1

enum AttackPattern {
	SINGLE_SHOT,
	TRIPLE_SHOT,
	CIRCLE_SHOT,
	SPIRAL_SHOT
}

var phase_patterns = {
	1: [AttackPattern.SINGLE_SHOT, AttackPattern.TRIPLE_SHOT],
	2: [AttackPattern.TRIPLE_SHOT, AttackPattern.CIRCLE_SHOT],
	3: [AttackPattern.CIRCLE_SHOT, AttackPattern.SPIRAL_SHOT]
}

signal enemy_dead(position: Vector2)
signal phase_changed(phase: int)
signal boss_defeated

func _ready() -> void:
	add_to_group("enemy")
	update_phase()
	setup_health_bar()
	randomize()

func _physics_process(_delta: float) -> void:
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)
	
	if distance_to_player > attack_range:
		velocity = direction * enemy_speed
		move_and_slide()

	else:
		velocity = Vector2.ZERO
		if can_attack:
			execute_attack_pattern()


func setup_health_bar() -> void:
	%HealthBar.max_value = max_health
	%HealthBar.value = health
	update_health_display()
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)

func update_health_display() -> void:
	health_label.text = str(health) + "/" + str(max_health)

func execute_attack_pattern() -> void:
	can_attack = false
	%BossSprite.play("jump")
	var patterns = phase_patterns[current_phase]
	var chosen_pattern = patterns[randi() % patterns.size()]
	
	match chosen_pattern:
		AttackPattern.SINGLE_SHOT:
			single_shot()
			await get_tree().create_timer(2.0, true).timeout
		AttackPattern.TRIPLE_SHOT:
			triple_shot()
			await get_tree().create_timer(3.0, true).timeout
		AttackPattern.CIRCLE_SHOT:
			circle_shot()
			await get_tree().create_timer(5.0, true).timeout
		AttackPattern.SPIRAL_SHOT:
			spiral_shot()
			await get_tree().create_timer(4.0, true).timeout
	
	can_attack = true

func single_shot() -> void:
	shoot_projectile(global_position.direction_to(player.global_position))

func triple_shot() -> void:
	var direction = global_position.direction_to(player.global_position)
	for i in range(-1, 2):
		var angle = direction.rotated(PI/6 * i)
		shoot_projectile(angle)
		await get_tree().create_timer(0.2, true).timeout

func circle_shot() -> void:
	var num_circles = rng.randf_range(3, 10) 
	var bullets_per_circle = rng.randf_range(8, 20)  
	var circle_delay = 0.3 
	var spiral_speed = rng.randf_range(PI/4, PI/16)  
	
	for circle in range(num_circles):
		for i in range(bullets_per_circle):
			var base_angle = (PI * 2 / bullets_per_circle) * i
			var offset_angle = spiral_speed * circle * i
			var angle = Vector2.RIGHT.rotated(base_angle + offset_angle)
			shoot_projectile(angle)
		
		if circle < num_circles - 1:
			await get_tree().create_timer(circle_delay, true).timeout

func spiral_shot() -> void:
	for i in range(16):
		var direction = global_position.direction_to(player.global_position)
		var angle = direction.rotated(PI/4 * i)
		shoot_projectile(angle)
		await get_tree().create_timer(0.1, true).timeout

func shoot_projectile(direction: Vector2) -> void:
	var proj = projectile.instantiate()
	get_tree().get_root().add_child(proj)
	proj.global_position = global_position
	proj.direction = direction
	proj.rotation = direction.angle() + PI/2

func update_phase() -> void:
	if health <= max_health * 0.3:
		current_phase = 3
		enemy_speed = 100
		phase_changed.emit(3)
	elif health <= max_health * 0.6:
		current_phase = 2
		enemy_speed = 50
		phase_changed.emit(2)

func take_damage(damage_amount) -> void:
	health -= damage_amount
	%HealthBar.value = health
	update_health_display()
	
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
		update_phase()
		var hurt_tween = create_tween()
		hurt_tween.tween_property(%BossSprite, "modulate", Color(3, 0.25, 0.25), 0.2)
		hurt_tween.chain().tween_property(%BossSprite, "modulate", Color(1, 1, 1), 0.2)
	else:
		enemy_dead.emit(global_position)
		boss_defeated.emit()
		await get_tree().create_timer(0.2).timeout
		popup.queue_free()
		queue_free()
