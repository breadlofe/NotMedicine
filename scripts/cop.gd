extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
var speed: float = 300.0
var target_position: Vector2
var last_position: Vector2 = Vector2.ZERO
var last_velocity: Vector2 = Vector2.ZERO
var state: String = "patrol"
var player: CharacterBody2D = null
var node_positions: Array

func _ready():
	node_positions = $"../PositionNodes".get_children()
	target_position = node_positions[randi() % node_positions.size()].position
	update_target_position(target_position)

func _process(delta):
	if state == "patrol":
		if position.distance_to(target_position) > 0.5:
			velocity = Vector2(nav_agent.get_next_path_position() - global_transform.origin).normalized() * speed
			move_and_slide()
		else:
			target_position = node_positions[randi() % node_positions.size()].position
			await get_tree().create_timer(1).timeout
			update_target_position(target_position)
	elif state == "chase":
		target_position = player.position
		update_target_position(target_position)
		if position.distance_to(target_position) > 0.5:
			velocity = Vector2(nav_agent.get_next_path_position() - global_transform.origin).normalized() * speed
			move_and_slide()

func update_target_position(target: Vector2):
	nav_agent.set_target_position(target)

func _on_cop_detect_area_body_entered(body):
	if body.is_in_group("player_group"):
		player = body
		state = "chase"

func _on_cop_detect_area_body_exited(body):
	if body.is_in_group("player_group"):
		last_position = player.position
		last_velocity = player.velocity
		player = null
		state = "patrol"
		var current_mark: Vector2 = node_positions[0].position
		for i in node_positions:
			var temp: float = abs(last_position - i.position).length()
			if temp < abs(current_mark - last_position).length():
				current_mark = i.position
		target_position = current_mark
		update_target_position(target_position)

func _on_cop_detect_player_body_entered(body):
	if body.is_in_group("player_group"):
		if body.has_method("arrest"):
			body.arrest(3, $".")


func _on_cop_detect_player_body_exited(body):
	if body.is_in_group("player_group"):
		if body.has_method("end_arrest"):
			body.end_arrest($".")
