extends Control


func _ready():
	hide()
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	%Options.options_closed.connect(_on_options_closed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if %Options.visible:
			%Options.hide()
			%PauseList.show()
		elif visible:
			unpause()
			Wwise.post_event("Resume_Adaptive_Music", self)
		else:
			pause()

func unpause():
	hide()
	var current_mode = GameState.targeting_mode
	GameState.targeting_mode_changed.emit(current_mode)
	get_tree().paused = false

func pause():
	Wwise.post_event("Pause_Adaptive_Music", self)
	show()
	get_tree().paused = true
	%PauseList.show()

func _on_resume_button_pressed() -> void:
	Wwise.post_event("Resume_Adaptive_Music", self)
	unpause()

func _on_options_button_pressed() -> void:
	%PauseList.hide()
	%Options.show()
	%Options.move_to_front()
	
func _on_options_closed() -> void:
	%Options.hide()
	%PauseList.show()

func _on_quit_button_pressed() -> void:
	Wwise.post_event("Stop_Adaptive_Music", self)
	
	await get_tree().create_timer(1, true).timeout
	
	Wwise.set_state("PlayerLife", "Defeated")
	Wwise.set_state("MusicState", "Menu")
	Wwise.set_rtpc_value("PlayerHealth", 100, self)
	Wwise.set_rtpc_value("KillCount", 0, self)
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
