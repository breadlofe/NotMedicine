extends CharacterBody2D

@onready var nav_agent = $NavigationAgent2D
var position_nodes: Array
var speed: float = 275.0
var target_position: Vector2
var last_position: Vector2 = Vector2.ZERO
var last_velocity: Vector2 = Vector2.ZERO
var state: String = "patrol"
var player: CharacterBody2D = null
var node_positions: Array

func _ready():
	position_nodes = $"../positionNodes".get_children()
	target_position = position_nodes[randi() % position_nodes.size()].position
	update_target_position(target_position)

func _process(delta):
	if player:
		if not player.coat_active:
			state = "chase"
		else:
			state = "patrol"
			
	if state == "patrol":
		if not nav_agent.is_target_reached():
			velocity = Vector2(nav_agent.get_next_path_position() - global_transform.origin).normalized() * speed
			move_and_slide()
		else:
			target_position = position_nodes[randi() % position_nodes.size()].position
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
		if body.coat_active:
			return
		state = "chase"

func _on_cop_detect_area_body_exited(body):
	if not player:
		return
	if body.is_in_group("player_group"):
		last_position = player.position
		last_velocity = player.velocity
		target_position = last_position + last_velocity
		update_target_position(target_position)
		player = null
		state = "patrol"

func _on_cop_detect_player_body_entered(body):
	if body.is_in_group("player_group"):
		if body.has_method("arrest"):
			body.arrest(3, $".")

func _on_cop_detect_player_body_exited(body):
	if body.is_in_group("player_group"):
		if body.has_method("end_arrest"):
			body.end_arrest($".")
