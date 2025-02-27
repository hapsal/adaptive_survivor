extends Control

@onready var buttons = %Buttons

func _ready() -> void:
	focus_button()
	add_to_group("main_menu")
	
	Wwise.set_state("MusicState", "Menu")
	Wwise.set_state("PlayerLife", "Defeated")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_pressed() -> void:
	var options = load("res://scenes/options.tscn").instantiate()
	get_tree().current_scene.add_child(options)
	options.options_closed.connect(_on_options_closed)
	%VBoxContainer.hide()

func _on_options_closed() -> void:
	show()
	%VBoxContainer.show()
	focus_button()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_visibility_changed() -> void:
		if visible:
			focus_button()
			
func focus_button() -> void:
	if buttons:
		var button: Button = buttons.get_child(0)
		if button is Button:
			button.grab_focus()
