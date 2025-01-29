extends Node2D

var time_elapsed = 0
var minutes
var seconds
var time_string
var timer_stopped = false

var xp = 1
var level = 0
var enemies_killed = 0

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
		"experience_value": 50,
	},
	"enemy2": {
		"time_requirement": 5,
		"experience_value": 3,
	},
	"enemy3": {
		"time_requirement": 10,
		"experience_value": 10,
	},
	"enemy4": {
		"time_requirement": 15,
		"experience_value": 15,
	},
	"enemy5": {
		"time_requirement": 20,
		"experience_value": 20,
	}
}

func _process(delta: float) -> void:
	if timer_stopped:
		return
	
	time_elapsed += delta
	minutes = time_elapsed / 60
	seconds = fmod(time_elapsed, 60)
	time_string = "%02d:%02d" % [minutes, seconds]
	%StopWatch.text = str(time_string)
	
	if %ExperienceBar.value == 100:
		%ExperienceBar.value = 0
		level += 1
		%Level.text = "Level: " +str(level)
		level_up.emit()

func spawn_enemy(enemy_type: String) -> void:
	var enemy_info = ENEMY_DATA[enemy_type]
	
	if time_elapsed >= enemy_info.time_requirement:
		var new_mob = ENEMY_SCENES[enemy_type].instantiate()
		%EnemySpawn.progress_ratio = randf() + %EnemySpawn.progress
		new_mob.global_position = %EnemySpawn.global_position
		add_child(new_mob)
		new_mob.connect("enemy_dead", Callable(self, "_on_enemy_killed").bind(enemy_info.experience_value))		

func _on_player_health_depleted() -> void:
	timer_stopped = true
	%GameOver.visible = true
	get_tree().paused = true

func _on_enemy_killed(experience_value: int) -> void:
	%ExperienceBar.value += experience_value
	enemies_killed += 1
	if experience_value == ENEMY_DATA.enemy1.experience_value:  # Only update text for enemy1
		%Killed.text = "Killed: " + str(enemies_killed)

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
