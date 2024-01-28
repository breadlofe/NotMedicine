extends Marker2D

@onready var cop: PackedScene = preload("res://scenes/cop.tscn")

func _ready():
	SignalBus.connect("cop_is_spawning", spawn_cop)

func spawn_cop():
	var cop_inst = cop.instantiate()
	add_child(cop_inst)
