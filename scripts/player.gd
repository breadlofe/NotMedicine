extends CharacterBody2D

@export var speed = 400

var item_active = false
var has_item = false
var superstar_active = false
var coat_active = false
var current_item = null

var in_patient_area = 0
var current_patients: Array[Node]
var cops_arresting_player: Array[Node]

@onready var timer = $ItemTimer as Timer
@onready var pause_menu = $Camera2D/MenuHUD/PauseMenu

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
	

	#rotate player.
	if(input_direction.length() > 0):
		$Footsteps.start_loop()
		rotation_degrees = rad_to_deg(atan2(input_direction.y, input_direction.x)) - 90
	else:
		$Footsteps.stop_loop()

	
	# hud cooldown effect
	if item_active:
		$Camera2D/ItemHUD/Control/ProgressBar.value = timer.time_left / timer.wait_time 
	
	var interact_input = Input.is_action_just_pressed("interact")
	if(interact_input):
		if in_patient_area > 0:
			SignalBus.on_player_attempt_funny.emit(current_patients.pop_back())
		elif has_item and not item_active:
			match current_item:
				ItemTypes.ItemTypes.SUPERSTAR:
					use_superstar()
				ItemTypes.ItemTypes.DOCTORS_OUTFIT:
					use_coat()
				ItemTypes.ItemTypes.CLOWN_HORN:
					pass
				
			
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
			$Camera2D/ItemHUD/Control/TextureRect.texture = load("res://sprites/NotMedicine.png")
		ItemTypes.ItemTypes.DOCTORS_OUTFIT:
			$Camera2D/ItemHUD/Control/TextureRect.texture = load("res://sprites/LabCoat.png")			
	
	
	current_item = type
			
func use_superstar():
	superstar_active = true
	item_active = true		
	
	timer.wait_time = 5
	timer.start()
	await timer.timeout
	has_item = false
	superstar_active = false
	item_active = false
	
	$Camera2D/ItemHUD/Control/TextureRect.texture = null

func use_coat():
	coat_active = true
	item_active = true
	
	timer.wait_time = 15
	timer.start()
	
	await timer.timeout

	has_item = false	
	coat_active = false
	item_active = false
	$Camera2D/ItemHUD/Control/TextureRect.texture = null
	
	


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
	


func _on_arrest_timer_timeout():
	get_tree().quit()


func _on_footsteps_finished():
	pass # Replace with function body.
