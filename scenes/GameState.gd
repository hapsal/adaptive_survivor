extends Node

signal targeting_mode_changed(new_mode)

var targeting_mode: GameEnums.TargetingMode = GameEnums.TargetingMode.MOUSE:
	set(value):
		targeting_mode = value
		targeting_mode_changed.emit(value)
		save_settings()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("Settings", "targeting_mode", targeting_mode)
	config.save("user://settings.cfg")

func load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load("user://settings.cfg")
	
	if error == OK:
		targeting_mode = config.get_value("Settings", "targeting_mode", GameEnums.TargetingMode.MOUSE)
