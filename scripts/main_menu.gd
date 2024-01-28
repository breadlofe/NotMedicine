extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.play_song(MusicManager.MainMenu)
	$VBoxContainer/Start.grab_focus()




func _on_start_pressed():
	MusicManager.play_song(MusicManager.Game)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_pressed():
	get_tree().quit()
