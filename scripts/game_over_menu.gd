extends Control

#@onready var main = $"../../../../"
@onready var player_node = get_node("/root/Game")

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Restart.grab_focus()
	print(player_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func _on_quit_pressed():
	get_tree().quit()
