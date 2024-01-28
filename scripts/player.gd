extends CharacterBody2D

@export var speed = 400
@export var horn_stun_time : int = 4

var item_active = false
var has_item = false
var superstar_active = false
var coat_active = false
var current_item = null

var in_patient_area = 0
var current_patients: Array[Node]
var cops_arresting_player: Array[Node]
var score : int = 0

@onready var timer = $ItemTimer as Timer
@onready var pause_menu = $Camera2D/MenuHUD/PauseMenu
@onready var score_label = $Camera2D/PlayerHUD/Score

# Player animations for walking
@onready var _animation_player = $AnimationPlayer

func _init():
	SignalBus.connect("on_pickup", pickup_handler)
	

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input_direction = input_direction.normalized()
		
	#superstar effect
	if superstar_active:
		velocity = input_direction * speed * 2
	else:
		velocity = input_direction * speed
	
	#rotate and animate player.
	if(input_direction.length() > 0):
		$Footsteps.start_loop()
		_animation_player.play("walk_animation")
		$Sprite2D.rotation_degrees = rad_to_deg(atan2(input_direction.y, input_direction.x)) - 90
	else:
		_animation_player.stop()
		$Footsteps.stop_loop()

	
	# hud cooldown effect
	if item_active:
		$Camera2D/PlayerHUD/HeldItem/ProgressBar.value = timer.time_left / timer.wait_time 
	
	var interact_input = Input.is_action_just_pressed("interact")
	if(interact_input):
		if in_patient_area > 0:
			#var patient_to_cure = null
			#var smallest_angle : float = 400
			#var look_vector = Vector2(-transform.x.y, transform.x.x)
			#for patient in current_patients:
		#		var vec_from_player = (patient.position - position).normalized()
		#		var dot = vec_from_player.dot(look_vector)
		#		var angle_between = abs(rad_to_deg(acos(dot)))
		#		if angle_between < smallest_angle or smallest_angle == 400:
		#			patient_to_cure = patient
		#			smallest_angle = angle_between
			
			
			var node = get_closest_patient()
			if node:
				SignalBus.on_player_attempt_funny.emit(node)


			#SignalBus.on_player_attempt_funny.emit(patient_to_cure)
			#current_patients.erase(patient_to_cure)
		elif has_item and not item_active:
			match current_item:
				ItemTypes.ItemTypes.SUPERSTAR:
					use_superstar()
				ItemTypes.ItemTypes.DOCTORS_OUTFIT:
					use_coat()
				ItemTypes.ItemTypes.CLOWN_HORN:
					use_horn()
				

func get_closest_patient():
	var ray = $RayCast2D as RayCast2D
	var shortest_len = INF
	var shortest_node = null
	for patient in current_patients:
		ray.target_position =  patient.global_position - global_position
		ray.force_raycast_update()
		
		var n = ray.get_collider() as Node

		if not n:
			continue
		if not n.is_in_group("patient_group"):
			continue
		else:
			var dist = ray.get_collision_point().distance_to(global_position)
			if dist < shortest_len:
				shortest_node = n
				shortest_len = dist
	if shortest_node:
		shortest_node = shortest_node.get_parent()
		current_patients.erase(shortest_node)
	return shortest_node


func _physics_process(delta):
	get_input()
	move_and_slide()

func _process(delta):
	if len(cops_arresting_player) <= 0:
		$ArrestTimer.stop()

func pickup_handler(type):
	has_item = true
	match type:
		ItemTypes.ItemTypes.SUPERSTAR:
			$Camera2D/PlayerHUD/HeldItem/TextureRect.texture = load("res://sprites/NotMedicine.png")
		ItemTypes.ItemTypes.CLOWN_HORN:
			$Camera2D/PlayerHUD/HeldItem/TextureRect.texture = load("res://sprites/Horn.png")
		ItemTypes.ItemTypes.DOCTORS_OUTFIT:
			$Camera2D/PlayerHUD/HeldItem/TextureRect.texture = load("res://sprites/LabCoat.png")			
	
	current_item = type
			
func use_superstar():
	superstar_active = true
	item_active = true		
	
	timer.wait_time = 5
	timer.start()
	
	var prev = MusicManager.stream
	MusicManager.play_song(MusicManager.Syringe)
	await timer.timeout
	MusicManager.play_song(prev)
	has_item = false
	superstar_active = false
	item_active = false
	
	$Camera2D/PlayerHUD/HeldItem/TextureRect.texture = null


func use_horn():
	item_active = true
	has_item = false
	
	SignalBus.on_horn_fired.emit(horn_stun_time)
	var horn_sound = $airhorn_sound as AudioStreamPlayer
	horn_sound.play()
	timer.wait_time = horn_stun_time
	timer.start()
	
	await timer.timeout
	
	item_active = false
	$Camera2D/PlayerHUD/HeldItem/TextureRect.texture = null


func use_coat():
	coat_active = true
	item_active = true
	
	timer.wait_time = 15
	timer.start()
	
	await timer.timeout

	has_item = false
	coat_active = false
	item_active = false
	$Camera2D/PlayerHUD/HeldItem/TextureRect.texture = null
	

func _on_area_2d_area_entered(area):
	if area.is_in_group("patient_group"):
		current_patients.append(area.get_parent())
		in_patient_area += 1
	
	if area.is_in_group("item_group"):
		if area.has_method("pickup") and not has_item:
			area.pickup()
		
func _on_area_2d_area_exited(area):
	if area.is_in_group("patient_group"):
		current_patients.erase(area.get_parent())
		in_patient_area -= 1
		max(in_patient_area, 0)

func arrest(time, cop:Node):
	if $ArrestTimer.is_stopped():
		$ArrestTimer.start(time)
	cops_arresting_player.append(cop)
	
func end_arrest(cop:Node):
	cops_arresting_player.erase(cop)
	

# LOSE STATE FOR GAME
func _on_arrest_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/UI/game_over_menu.tscn")


func _on_footsteps_finished():
	pass # Replace with function body.
	

func adjust_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)
