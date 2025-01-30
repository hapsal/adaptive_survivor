extends Node2D

# Time tracking
var time_elapsed = 0
var minutes
var seconds
var time_string
var timer_stopped = false

# Experience and Level System
const BASE_XP_REQ: float = 100.0
const XP_SCALE_FACTOR: float = 1.2
const MAX_LEVEL: int = 99

var current_xp: float = 0.0
var xp_required: float = BASE_XP_REQ
var level = 1
var enemies_killed = 0

# Time-based XP multiplier
var time_multiplier: float = 1.0

signal level_up

const ENEMY_SCENES = {
	"enemy1": preload("res://scenes/enemy.tscn"),
	"enemy2": preload("res://scenes/enemy2.tscn"),
	"enemy3": preload("res://scenes/enemy3.tscn"),
	"enemy4": preload("res://scenes/enemy4.tscn"),
	"enemy5": preload("res://scenes/enemy5.tscn")
}

const ENEMY_DATA = {
	"enemy1": {
		"time_requirement": 0,
		"experience_value": 5,
		"weight": 1.0
	},
	"enemy2": {
		"time_requirement": 30,
		"experience_value": 12,
		"weight": 0.8
	},
	"enemy3": {
		"time_requirement": 60,
		"experience_value": 45,
		"weight": 0.5
	},
	"enemy4": {
		"time_requirement": 15,
		"experience_value": 15,
		"weight": 0.7
	},
	"enemy5": {
		"time_requirement": 20,
		"experience_value": 25,
		"weight": 0.6
	}
}

func _ready() -> void:
	update_xp_requirement()
	%Level.text = "Level: " + str(level)
	%Killed.text = "Killed: " + str(enemies_killed)

func _process(delta: float) -> void:
	if timer_stopped:
		return
	
	update_time(delta)
	update_time_multiplier()
	update_experience_bar()

func update_time(delta: float) -> void:
	time_elapsed += delta
	minutes = time_elapsed / 60
	seconds = fmod(time_elapsed, 60)
	time_string = "%02d:%02d" % [minutes, seconds]
	%StopWatch.text = str(time_string)

func update_time_multiplier() -> void:
	time_multiplier = 1.0 + (time_elapsed / 60.0) * 0.1  # 10% increase per minute

func update_experience_bar() -> void:
	%ExperienceBar.max_value = xp_required
	%ExperienceBar.value = current_xp
	
	if current_xp >= xp_required and level < MAX_LEVEL:
		on_level_up()

func on_level_up() -> void:
	current_xp -= xp_required
	level += 1
	update_xp_requirement()
	%Level.text = "Level: " + str(level)
	level_up.emit()

func update_xp_requirement() -> void:
	xp_required = calculate_xp_requirement(level)

func calculate_xp_requirement(lvl: int) -> float:
	return BASE_XP_REQ * pow(XP_SCALE_FACTOR, lvl - 1)

func spawn_enemy(enemy_type: String) -> void:
	var enemy_info = ENEMY_DATA[enemy_type]
	
	if time_elapsed >= enemy_info.time_requirement:
		var spawn_chance = calculate_spawn_chance(enemy_type)
		if randf() <= spawn_chance:
			var new_mob = ENEMY_SCENES[enemy_type].instantiate()
			%EnemySpawn.progress_ratio = randf() + %EnemySpawn.progress
			new_mob.global_position = %EnemySpawn.global_position
			add_child(new_mob)
			new_mob.connect("enemy_dead", Callable(self, "_on_enemy_killed").bind(enemy_info.experience_value))

func calculate_spawn_chance(enemy_type: String) -> float:
	var base_weight = ENEMY_DATA[enemy_type].weight
	
	# Adjust weights based on game time
	match enemy_type:
		"enemy1": return base_weight * max(1.0 - time_elapsed/300.0, 0.2)  # Reduces over time
		"enemy2": return base_weight * min(time_elapsed/60.0, 1.0)         # Increases over time
		"enemy3": return base_weight * min(time_elapsed/120.0, 1.0)        # Slower increase
		"enemy4": return base_weight
		"enemy5": return base_weight * min(time_elapsed/90.0, 1.0)
	return base_weight

func _on_enemy_killed(experience_value: int) -> void:
	var adjusted_xp = experience_value * time_multiplier
	
	# Apply catch-up bonus if player is behind expected level
	adjusted_xp *= calculate_catch_up_bonus()
	
	current_xp += adjusted_xp
	enemies_killed += 1
	if experience_value == ENEMY_DATA.enemy1.experience_value:
		%Killed.text = "Killed: " + str(enemies_killed)

func calculate_catch_up_bonus() -> float:
	var expected_level = floor(time_elapsed / 60.0) + 1  # Expected level per minute
	if level < expected_level:
		return 1.0 + (expected_level - level) * 0.1  # 10% bonus per level behind
	return 1.0

func _on_player_health_depleted() -> void:
	timer_stopped = true
	%GameOver.visible = true
	get_tree().paused = true

# Enemy spawn timers
func _on_ball_spawner_timeout() -> void:
	spawn_enemy("enemy1")

func _on_snök_spawner_timeout() -> void:
	spawn_enemy("enemy2")

func _on_elite_spawner_timeout() -> void:
	spawn_enemy("enemy3")

func _on_doggo_spawner_timeout() -> void:
	spawn_enemy("enemy4")

func _on_human_spawner_timeout() -> void:
	spawn_enemy("enemy5")
