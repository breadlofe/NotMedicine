extends StaticBody2D

@onready var spawn_point = $SpawnPoint
@onready var spawn_timer = $SpawnTimer

@export var spawn_time : int = 10


func _ready():
	spawn_timer.set_wait_time(spawn_time)
	spawn_patient()


func spawn_patient():
	var patient = preload("res://scenes/patient.tscn").instantiate()
	patient.position = spawn_point.global_position
	patient.rotation = self.rotation
	patient.bed = self
	$"../../../".add_child.call_deferred(patient)


func on_patient_removed():
	spawn_timer.start()


func _on_spawn_timer_timeout():
	spawn_patient()
