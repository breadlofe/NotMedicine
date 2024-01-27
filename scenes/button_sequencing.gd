extends CanvasLayer


func _init():
	SignalBus.connect("on_player_attempt_funny", begin_input_sequence)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func begin_input_sequence():
	$ColorRect.color = Color(255, 0, 255, 255)
