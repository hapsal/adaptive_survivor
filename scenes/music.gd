extends Node2D

func _ready() -> void:
	Wwise.set_state("MusicState", "Menu")
	Wwise.set_state("PlayerLife", "Alive")
