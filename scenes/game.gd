extends Node2D

var time_elapsed = 0
var minutes
var seconds
var time_string
var timer_stopped = false

const BASE_XP_REQ: float = 100.0
const XP_SCALE_FACTOR: float = 1.2
const MAX_LEVEL: int = 99

var current_xp: float = 0.0
var xp_required: float = BASE_XP_REQ
var level = 1
var enemies_killed = 0
var elite_spawn_cooldown = 15.0  
var last_elite_spawn_time = -15.0

var time_multiplier: float = 0.8

var present_spawned = false
const PRESENT_SPAWN_TIME = 120.0

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
		"initial_weight": 5.0,
		"mid_weight": 0.8,      
		"final_weight": 0.4  
	},
	"enemy2": {
		"time_requirement": 20,
		"experience_value": 10,
		"initial_weight": 0.0,
		"mid_weight": 0.8,      
		"final_weight": 0.1    
	},
	"enemy3": { # Elite
		"time_requirement": 60,
		"experience_value": 45,
		"initial_weight": 0.0,
		"mid_weight": 0.4,    
		"final_weight": 0.1    
	},
	"enemy4": {
		"time_requirement": 30,
		"experience_value": 10,
		"initial_weight": 0.0,
		"mid_weight": 0.4,     
		"final_weight": 0.2    
	},
	"enemy5": {
		"time_requirement": 30,
		"experience_value": 15,
		"initial_weight": 0.0,
		"mid_weight": 0.3,      
		"final_weight": 0.2
	}
}

@onready var xp_drop = preload("res://scenes/xp_treat.tscn")
@onready var present = preload("res://scenes/present.tscn")
@onready var boss_scene = preload("res://scenes/boss_enemy.tscn")
@onready var spawn_timer = %EnemySpawner

func _ready() -> void:
	update_xp_requirement()
	%Level.text = "Level: " + str(level)
	%Killed.text = "Killed: " + str(enemies_killed)
	adjust_spawn_timer()
	spawn_timer.start()
	%GameOver.hide()
	%VictoryScreen.hide()
	
	Wwise.set_state("EnemyTypes", "NoEnemy")
	Wwise.set_state("MusicState", "Combat")
	Wwise.set_state("PlayerLife", "Alive")

func _process(delta: float) -> void:
	if timer_stopped:
		return
	
	update_time(delta)
	update_time_multiplier()
	update_experience_bar()
	handle_present_spawn()

func update_time(delta: float) -> void:
	time_elapsed += delta
	minutes = time_elapsed / 60
	seconds = fmod(time_elapsed, 60)
	time_string = "%02d:%02d" % [minutes, seconds]
	%StopWatch.text = str(time_string)

func update_time_multiplier() -> void:
	time_multiplier = 1.0 + (time_elapsed / 60.0) * 0.1

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
		if enemy_type == "enemy3":
			if time_elapsed - last_elite_spawn_time < elite_spawn_cooldown:
				return
	
	if time_elapsed >= enemy_info.time_requirement:
		var spawn_chance = calculate_spawn_chance(enemy_type)
		if randf() <= spawn_chance:
			var new_mob = ENEMY_SCENES[enemy_type].instantiate()
			%EnemySpawn.progress_ratio = randf() + %EnemySpawn.progress
			new_mob.global_position = %EnemySpawn.global_position
			add_child(new_mob)
			new_mob.enemy_dead.connect(func(pos): _on_enemy_killed(enemy_info.experience_value, pos))
			
			if enemy_type == "enemy3":
				last_elite_spawn_time = time_elapsed 
				Wwise.set_state("EnemyTypes", "EliteEnemy")

func calculate_spawn_chance(enemy_type: String) -> float:
	var enemy_data = ENEMY_DATA[enemy_type]
	
	const EARLY_GAME = 30.0
	const MID_GAME = 60.0
	
	var phase_progress: float
	
	if time_elapsed < EARLY_GAME:
		phase_progress = time_elapsed / EARLY_GAME
		return lerp(enemy_data.initial_weight, enemy_data.mid_weight, phase_progress)
	elif time_elapsed < MID_GAME:
		phase_progress = (time_elapsed - EARLY_GAME) / (MID_GAME - EARLY_GAME)
		return lerp(enemy_data.mid_weight, enemy_data.final_weight, phase_progress)
	else:
		return enemy_data.final_weight

func _on_enemy_killed(experience_value: int, enemy_position: Vector2) -> void:
	enemies_killed += 1
	Wwise.set_rtpc_value("KillCount", enemies_killed, null)
	%Killed.text = "Killed: " + str(enemies_killed)
		
	spawn_xp_treat(enemy_position, experience_value)

func spawn_xp_treat(spawn_position: Vector2, xp_value: float) -> void:
	var new_xp = xp_drop.instantiate()
	new_xp.global_position = spawn_position
	new_xp.experience_value = xp_value
	call_deferred("add_child", new_xp)

func add_experience(value: float) -> void:
	var adjusted_xp = value * time_multiplier
	adjusted_xp *= calculate_catch_up_bonus()
	
	current_xp += adjusted_xp
	update_experience_bar()		
		
func calculate_catch_up_bonus() -> float:
	var expected_level = floor(time_elapsed / 60.0) + 1
	if level < expected_level:
		return 1.0 + (expected_level - level) * 0.1 
	return 1.0

func _on_player_health_depleted() -> void:
	timer_stopped = true
	get_tree().paused = true
	%GameOver.show()

func adjust_spawn_timer() -> void:
	var base_time = 1.8
	var min_time = 0.6
	
	var spawn_interval = base_time - (time_elapsed / 100.0) * (base_time - min_time)
	spawn_interval = clamp(spawn_interval, min_time, base_time)
	spawn_timer.wait_time = spawn_interval

func _on_enemy_spawner_timeout():
	adjust_spawn_timer()
		
	var wave_intensity = min(time_elapsed / 30.0, 4.0) 
	var spawns_this_wave = ceil(wave_intensity)
	
	for _i in range(spawns_this_wave):
		var total_weight = 0.0
		var available_enemies = []
		
		for enemy_type in ENEMY_DATA.keys():
			if time_elapsed >= ENEMY_DATA[enemy_type].time_requirement:
				var weight = calculate_spawn_chance(enemy_type)
				total_weight += weight
				available_enemies.append({
					"type": enemy_type,
					"weight": weight
				})
		
		if total_weight > 0:
			var random_value = randf() * total_weight
			var current_sum = 0.0
			
			for enemy in available_enemies:
				current_sum += enemy.weight
				if random_value <= current_sum:
					spawn_enemy(enemy.type)
					break

func handle_present_spawn() -> void:
	if !present_spawned and time_elapsed >= PRESENT_SPAWN_TIME:
		present_spawned = true
		stop_enemy_spawning()
		spawn_final_present()

func stop_enemy_spawning() -> void:
	spawn_timer.stop()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()

func spawn_final_present() -> void:
	var spawn_position = %EnemySpawn.global_position
	var new_present = present.instantiate()
	new_present.global_position = spawn_position
	new_present.experience_value = 3000
	new_present.picked_up.connect(_on_present_picked_up)
	call_deferred("add_child", new_present)

func _on_present_picked_up() -> void:
	Wwise.set_state("MusicState", "Boss")
	
	var player = get_tree().get_first_node_in_group("player")
	var xp_treats = get_tree().get_nodes_in_group("xp_treats")
	
	for treat in xp_treats:
		treat.start_moving_to_player(player)
	
	player.heal(100)
	
	var timer = get_tree().create_timer(20.0)
	await timer.timeout
	
	var boss = boss_scene.instantiate()
	boss.global_position = %EnemySpawn.global_position
	add_child(boss)
	boss.boss_defeated.connect(_on_boss_defeated)

func _on_boss_defeated() -> void:
	Wwise.set_rtpc_value("PlayerHealth", 100, null)
	show_victory_screen()

func show_victory_screen() -> void:
	Wwise.set_state("BossState", "Defeated")
	timer_stopped = true
	get_tree().paused = true
	%VictoryScreen.show()

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_to_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
