extends Node2D

@onready var pause_menu = $player.pause_menu
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		toggle_pause()

func toggle_pause():
	if paused:
		MusicManager.play_song(MusicManager.Game)
		pause_menu.hide()
		get_tree().paused = false
	else:
		MusicManager.play_song(MusicManager.PauseMenu)
		pause_menu.show()
		pause_menu.on_reveal()
		get_tree().paused = true
	paused = !paused
