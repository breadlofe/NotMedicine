extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
var speed: float = 200.0
var target_position: Vector2
var state: String = "patrol"
var player: CharacterBody2D = null
var node_positions: Array

func _ready():
	node_positions = $"../PositionNodes".get_children()
	target_position = node_positions[randi() % node_positions.size()].position
	update_target_position(target_position)

func _process(delta):
	if position.distance_to(target_position) > 0.5:
		velocity = Vector2(nav_agent.get_next_path_position() - global_transform.origin).normalized() * speed
		move_and_slide()
	else:
		target_position = node_positions[randi() % node_positions.size()].position
		update_target_position(target_position)

func update_target_position(target: Vector2):
	nav_agent.set_target_position(target)

func _on_cop_detect_area_body_entered(body):
	if body.is_in_group("player_group"):
		player = body
		state = "chase"
		print("PLAYER ENTERED")

func _on_cop_detect_area_body_exited(body):
	if body.is_in_group("player_group"):
		player = body
		state = "patrol"
		print("PLAYER EXITED")
