extends Control

signal options_closed
signal targeting_mode_changed(mode: int)

@onready var targeting_checkbox = %Auto

func _ready() -> void:
	targeting_checkbox.toggled.connect(_on_auto_toggled)
	targeting_checkbox.button_pressed = (GameState.targeting_mode == GameEnums.TargetingMode.AUTO)

func _on_back_pressed() -> void:
	options_closed.emit()
	queue_free()

func _on_auto_toggled(toggled_on: bool) -> void:
	GameState.targeting_mode = GameEnums.TargetingMode.AUTO if toggled_on else GameEnums.TargetingMode.MOUSE
