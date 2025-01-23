extends Sprite2D

var d := 0.0
var radius := 150.0
var speed := 1.0

func _process(delta: float) -> void:
	d += delta
	position = Vector2(sin(d * speed) * radius, cos(d * speed) * radius) + Vector2(250, 250)
