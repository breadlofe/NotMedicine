extends CharacterBody2D

enum States {PATROL, CHASE, IDLE}

@export var detection_radius : int
@export var speed : int = 200
@export var patrol_component : Node2D
@export var idle_time : float = 2.5
var visibility_color = Color(0.867, 0.91, 0.247, 0.1)
var target
var target_position
var state = States.PATROL
var pre_idle_state = States.PATROL


# Called when the node enters the scene tree for the first time.
func _ready():
	var shape = CircleShape2D.new()
	shape.radius = detection_radius
	$Visibility/CollisionShape2D.shape = shape
	$IdleTimer.set_wait_time(idle_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	if state == States.PATROL:
		velocity = patrol_component.direction * speed
		move_and_slide()
	if state == States.CHASE:
		if target:
			target_position = target.position
			var target_position_normalized = (target_position - position).normalized()
			if position.distance_to(target_position) > 20:
				velocity = target_position_normalized * speed
				move_and_slide()
		

func _on_visibility_body_entered(body):
	if target:
		return
	elif body.is_in_group("Player"):
		target = body
		state = States.CHASE
		if not $IdleTimer.is_stopped():
			$IdleTimer.stop()


func _on_visibility_body_exited(body):
	if body == target:
		target = null
		pre_idle_state = state
		state = States.IDLE
		$IdleTimer.start()


func _draw():
	draw_circle(Vector2(), detection_radius, visibility_color)


func _on_idle_timer_timeout():
	state = pre_idle_state
	
	
func _on_patrol_reached_patrol_point():
	pre_idle_state = state
	state = States.IDLE
	$IdleTimer.start()
