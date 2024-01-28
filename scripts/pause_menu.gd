extends Control

@onready var main = $"../../../../"


func _ready():
	on_reveal()


func on_reveal():
	$VBoxContainer/Resume.grab_focus()


func _on_resume_pressed():
	if main:
		main.toggle_pause()
	


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
