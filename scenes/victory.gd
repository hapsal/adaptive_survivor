extends CanvasLayer


func _ready() -> void:
	pass # Replace with function body.

func _on_menu_button_pressed() -> void:
	Wwise.post_event("Stop_Adaptive_Music", self)
	
	await get_tree().create_timer(1, true).timeout
	
	Wwise.set_state("PlayerLife", "Defeated")
	Wwise.set_state("MusicState", "Menu")
	Wwise.set_rtpc_value("PlayerHealth", 100, self)
	Wwise.set_rtpc_value("KillCount", 0, self)
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
