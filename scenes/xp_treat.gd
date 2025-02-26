extends Area2D

var experience_value: float = 1.0
var healing_value: float = 1.0
var move_speed: float = 100.0
var is_moving_to_player: bool = false
var player: Node2D = null

func _ready() -> void:
	position += Vector2(randf_range(-10, 10), randf_range(-10, 10))
	%Treat.play("bounce")

func _physics_process(delta: float) -> void:
	if is_moving_to_player and player:
		var direction = global_position.direction_to(player.global_position)
		global_position += direction * move_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collect_xp()
		if body.has_method("heal"):
			body.heal(healing_value)

func collect_xp() -> void:
	var game = get_node("/root/Game")
	game.add_experience(experience_value)
	
	queue_free()

func start_moving_to_player(player_body: Node2D) -> void:
	player = player_body
	is_moving_to_player = true
	move_speed = 200.0  
