extends Sprite2D

var patient_sprite_paths = ["res://sprites/Character_Patient_01.png", "res://sprites/Character_Patient_02.png"]
var rng = RandomNumberGenerator.new()
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var sprite_to_pick = rng.randi_range(0, 1)
	var sprite = load(patient_sprite_paths[sprite_to_pick])
	self.texture = sprite
	
