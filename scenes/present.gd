extends Area2D

var can_pickup = false
@onready var pickup_label = %PickupText
@onready var arrow = preload("res://scenes/arrow.tscn")
@onready var confetti = preload("res://scenes/confetti.tscn") 
var experience_value: float
var arrow_instance

signal picked_up

func _ready() -> void:
	pickup_label.hide()
	setup_arrow()

func _physics_process(_delta: float) -> void:
	if can_pickup:
		pickup_label.show()
		arrow_instance.hide()
		if Input.is_action_just_pressed("pickup"):
			pickup_item()
	else:
		pickup_label.hide()
		update_arrow_position()

func setup_arrow() -> void:
	arrow_instance = arrow.instantiate()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(arrow_instance)
	add_child(canvas_layer)

func update_arrow_position() -> void:
	if !arrow_instance:
		return
		
	var viewport_rect = get_viewport_rect()
	var camera = get_viewport().get_camera_2d()
	var screen_center = camera.get_screen_center_position()
	var screen_size = viewport_rect.size
	
	var present_pos = global_position - screen_center + screen_size/2
	
	if viewport_rect.has_point(present_pos):
		arrow_instance.hide()
		return
	
	arrow_instance.show()
	
	var angle = (present_pos - screen_size/2).angle()
	var screen_radius = screen_size.length() / 2
	var edge_point = screen_size/2 + Vector2(cos(angle), sin(angle)) * screen_radius
	
	edge_point.x = clamp(edge_point.x, 100, screen_size.x - 100)
	edge_point.y = clamp(edge_point.y, 100, screen_size.y - 100)
	
	arrow_instance.position = edge_point
	var direction_to_present = (present_pos - edge_point).angle()
	arrow_instance.rotation = direction_to_present + PI/2


func spawn_confetti() -> void:
	var conf = confetti.instantiate()
	conf.global_position = global_position
	get_parent().add_child(conf)
	
func pickup_item():
	var game = get_node("/root/Game")
	game.add_experience(experience_value)
	spawn_confetti()
	picked_up.emit()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_pickup = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_pickup = false
