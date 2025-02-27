extends CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = true
	lifetime = 4
	await get_tree().create_timer(lifetime * 2.2).timeout
	queue_free()
