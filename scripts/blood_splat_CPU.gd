extends CPUParticles2D


@onready var TimeCreated = Time.get_ticks_msec()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Time.get_ticks_msec() - TimeCreated > 1000:
		queue_free()
