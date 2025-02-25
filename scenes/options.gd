extends Control

signal options_closed
signal targeting_mode_changed(mode: int)

@onready var targeting_checkbox = %Auto
@onready var music_volume = %MusicVolume

func _ready() -> void:
	targeting_checkbox.toggled.connect(_on_auto_toggled)
	targeting_checkbox.button_pressed = (GameState.targeting_mode == GameEnums.TargetingMode.AUTO)
	music_volume.changed.connect(_on_music_volume_value_changed)

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
