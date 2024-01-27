extends CharacterBody2D

@export var speed = 400

var in_patient_area = 0
var current_patients: Array[Node]


func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	
	var interact_input = Input.is_action_just_pressed("interact")
	if(interact_input):
		SignalBus.on_player_attempt_funny.emit(current_patients.pop_back())

func _physics_process(delta):
	get_input()
	move_and_slide()



func _on_area_2d_area_entered(area):
	if area.is_in_group("patient_group"):
		current_patients.append(area.get_parent())
		in_patient_area += 1
		

func _on_area_2d_area_exited(area):
	if area.is_in_group("patient_group"):
		current_patients.erase(area.get_parent())
		in_patient_area -= 1
		max(in_patient_area, 0)
