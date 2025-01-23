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

func spawn_enemy():
	var new_mob = preload("res://scenes/enemy.tscn").instantiate()
	%EnemySpawn.progress_ratio = randf()
	new_mob.global_position = %EnemySpawn.global_position
	add_child(new_mob)
	new_mob.connect("enemy_dead", Callable(self, "_on_enemy_dead"))

func spawn_enemy2():
	if time_elapsed >= 30:
		var new_mob = preload("res://scenes/enemy2.tscn").instantiate()
		%EnemySpawn.progress_ratio = randf() + %EnemySpawn.progress
		new_mob.global_position = %EnemySpawn.global_position
		add_child(new_mob)
		new_mob.connect("enemy_dead", Callable(self, "_on_enemy2_dead"))
		
func spawn_enemy3():
	if time_elapsed >= 60:
		var new_mob = preload("res://scenes/enemy3.tscn").instantiate()
		%EnemySpawn.progress_ratio = randf() + %EnemySpawn.progress
		new_mob.global_position = %EnemySpawn.global_position
		add_child(new_mob)
		new_mob.connect("enemy_dead", Callable(self, "_on_enemy3_dead"))

func _on_player_health_depleted() -> void:
	timer_stopped = true
	%GameOver.visible = true
	get_tree().paused = true

func _on_enemy_dead():
	%ExperienceBar.value += 50
	enemies_killed += 1
	%Killed.text = "Killed: " + str(enemies_killed)
	
func _on_enemy2_dead():
	%ExperienceBar.value += 3
	enemies_killed += 1
	
func _on_enemy3_dead():
	%ExperienceBar.value += 10
	enemies_killed += 1

func _on_ball_spawner_timeout() -> void:
	spawn_enemy()

func _on_snök_spawner_timeout() -> void:
	spawn_enemy2()

func _on_elite_spawner_timeout() -> void:
	spawn_enemy3()
