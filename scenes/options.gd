extends Control

signal options_closed

@onready var targeting_checkbox = %Auto
@onready var music_volume = %MusicVolume

func _ready() -> void:
	music_volume.value = Wwise.get_rtpc_value("MusicVolume", null)
	targeting_checkbox.set_pressed_no_signal(GameState.targeting_mode == GameEnums.TargetingMode.AUTO)

func _on_back_pressed() -> void:
	options_closed.emit()
	hide()

func _on_auto_toggled(toggled_on: bool) -> void:
	GameState.targeting_mode = GameEnums.TargetingMode.AUTO if toggled_on else GameEnums.TargetingMode.MOUSE

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

func _on_music_volume_value_changed(value: float) -> void:
	var wwise_value = value
	Wwise.set_rtpc_value("MusicVolume", wwise_value, null)
