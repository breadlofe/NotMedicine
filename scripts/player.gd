extends CharacterBody2D

@export var speed = 400

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()


func _on_area_2d_area_entered(area):
	if(area.is_in_group("patient_group")):
		print("shit my pants")
		SignalBus.on_player_attempt_funny.emit()
		#actually call some signal that connects to the
		#input thing



