extends AudioStreamPlayer

@onready var MainMenu = preload("res://sfx/MainMenu.wav")
@onready var PauseMenu = preload("res://sfx/PauseMenu.wav")
@onready var Game = preload("res://sfx/GameSong.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	play_song(MainMenu)

func play_song(_stream :AudioStream):
	stream = _stream
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
