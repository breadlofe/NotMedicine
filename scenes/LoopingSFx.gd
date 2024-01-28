extends AudioStreamPlayer2D

@onready var timer = $Timer

func _ready():
	pass
	
func start_loop():
	if(timer.is_stopped()):	
		play()
		timer.start()

func stop_loop():
	stop()

func _on_timer_timeout():
	pitch_scale = randf_range(0.7, 1.5)
	play()

func _on_finished():
	stop()
