extends Node2D

var powerup_weights = {ItemTypes.ItemTypes.CLOWN_HORN : 1, ItemTypes.ItemTypes.DOCTORS_OUTFIT : 1, ItemTypes.ItemTypes.SUPERSTAR: 0.5}
var weight_total : float = 0
var rng = RandomNumberGenerator.new()

func _ready():
	for item in powerup_weights:
		weight_total += powerup_weights[item]

func spawn_powerup():
	var random = randf_range(0.0, weight_total)
	var cursor = 0
	var powerup_to_spawn = null
	for item in powerup_weights:
		cursor += powerup_weights[item]
		if cursor >= random:
			powerup_to_spawn = item
			break
	var new_powerup = null
	match powerup_to_spawn:
		ItemTypes.ItemTypes.SUPERSTAR:
				new_powerup = preload("res://scenes/invincibility_item.tscn").instantiate()
		ItemTypes.ItemTypes.DOCTORS_OUTFIT:
				new_powerup = preload("res://scenes/coat_item.tscn").instantiate()
		ItemTypes.ItemTypes.CLOWN_HORN:
				new_powerup = preload("res://scenes/horn.tscn").instantiate()
	self.add_child(new_powerup)
		
		
