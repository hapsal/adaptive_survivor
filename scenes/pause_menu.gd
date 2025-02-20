extends Control

func _ready():
	hide()
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	%Resume_Button.pressed.connect(_on_resume_button_pressed)
	%Options_Button.pressed.connect(_on_options_button_pressed)
	%Quit_Button.pressed.connect(_on_quit_button_pressed)
	
	%Options.options_closed.connect(_on_options_closed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if %Options.visible:
			%Options.hide()
			%PauseList.show()
		elif visible:
			unpause()
		else:
			pause()

func unpause():
	hide()
	get_tree().paused = false

func pause():
	show()
	get_tree().paused = true
	%PauseList.show()

func _on_resume_button_pressed() -> void:
	unpause()

func _on_options_button_pressed() -> void:
	%PauseList.hide()
	%Options.show()
	
	# Options menu ei vielä toimi mm. auto targeting ei vaihdu
	
func _on_options_closed() -> void:
	%Options.hide()
	%PauseList.show()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
