extends Node2D

func _ready() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
