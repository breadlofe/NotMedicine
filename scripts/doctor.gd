extends CharacterBody2D

enum States {PATROL, CHASE, IDLE, STUNNED}

@export var detection_radius : int
@export var speed : int = 200
@export var patrol_component : Node2D
@export var patrol_point_group : String
@export var idle_time : float = 2.5

@onready var nav_agent = $NavigationAgent2D
@onready var idle_timer = $IdleTimer
@onready var stun_timer = $StunTimer

var visibility_color = Color(0.867, 0.91, 0.247, 0.1)
var target
var target_position
var state = States.PATROL
var pre_stun_state : int


# Called when the node enters the scene tree for the first time.
func _ready():
	if patrol_component:
		patrol_component.group_name = patrol_point_group
		patrol_component._initialize()
	var shape = CircleShape2D.new()
	shape.radius = detection_radius
	$Visibility/CollisionShape2D.shape = shape
	idle_timer.set_wait_time(idle_time)
	SignalBus.on_horn_fired.connect(on_stun)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	if state == States.PATROL:
		if target:
			state = States.CHASE
		else:
			nav_agent.set_target_position(patrol_component.current_patrol_point.position)
			var move_dir = (nav_agent.get_next_path_position() - position).normalized()
			velocity = move_dir * speed
			move_and_slide()
	if state == States.CHASE:
		if target:
			nav_agent.set_target_position(target.position)
			var move_dir = (nav_agent.get_next_path_position() - position).normalized()
			if position.distance_to(target.position) > 20:
				velocity = move_dir * speed
				move_and_slide()
		else:
			state = States.PATROL
		

func _on_visibility_body_entered(body):
	if target:
		return
	elif body.is_in_group("player_group"):
		target = body
		if state != States.STUNNED:
			state = States.CHASE
			if not idle_timer.is_stopped():
				idle_timer.stop()


func _on_visibility_body_exited(body):
	if body == target:
		target = null
		if state != States.STUNNED:
			state = States.IDLE
			idle_timer.start()


func _draw():
	draw_circle(Vector2(), detection_radius, visibility_color)


func _on_idle_timer_timeout():
	state = States.PATROL
	
	
func _on_stun_timer_timeout():
	state = pre_stun_state
	
	
func _on_patrol_reached_patrol_point():
	state = States.IDLE
	idle_timer.start()
	

func on_stun(stun_time):
	pre_stun_state = state
	state = States.STUNNED
	stun_timer.set_wait_time(stun_time)
	stun_timer.start()
