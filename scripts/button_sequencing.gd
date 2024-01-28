extends CanvasLayer

signal cop_is_spawning

@onready var player = $"../../"

@export var textures: Array[CompressedTexture2D]
# Packed scene for particle emissions.
@export var deathParticle: PackedScene
@export var funnyParticle: PackedScene

var is_active: bool = false
var input_sequence: Array[int]
var input_texture_rects_left: Array[Node]

var current_patient = null

func _init():
	SignalBus.connect("on_player_attempt_funny", begin_input_sequence)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _unhandled_input(event):
	if not is_active:
		return
		
	if event is InputEventKey:
		if event.pressed and not event.is_echo():
			var keycode = input_sequence.pop_front()
			if (keycode != event.keycode):
				apply_consequences()
			else:
				var icon = input_texture_rects_left.pop_front() as TextureRect
				icon.texture = null
				if len(input_texture_rects_left) <= 0:
					apply_rewards()
					

func begin_input_sequence(patient):
	input_sequence.clear()
	is_active = true
	var icons = $HBoxContainer.get_children()
	for icon in icons:
		var icon_text_rect = icon as TextureRect
		icon_text_rect.texture = select_random()
	
	current_patient = patient
	input_texture_rects_left = icons
	
func select_random() -> Texture2D:
	var texture = textures.pick_random() as Texture2D
	if texture.resource_path.to_upper().contains("LEFT"):
		input_sequence.append(KEY_LEFT)
	if texture.resource_path.to_upper().contains("RIGHT"):
		input_sequence.append(KEY_RIGHT)
	if texture.resource_path.to_upper().contains("DOWN"):
		input_sequence.append(KEY_DOWN)
	if texture.resource_path.to_upper().contains("UP"):
		input_sequence.append(KEY_UP)
	return texture

func apply_rewards():
	is_active = false
	current_patient.bed.on_patient_removed()
	var patient_node = current_patient as Node
	patient_node.queue_free()
	var reward = [$Reward1 as AudioStreamPlayer, $Reward2 as AudioStreamPlayer]
	reward.pick_random().play()
	player.adjust_score(5)
	particle_emission(current_patient.global_position, current_patient.global_rotation, 1)
	clear_textures()
	
	# Spawn Powerups
	player.total_cures += 1
	if player.total_cures % player.cures_till_powerup == 0:
		var p_spawners = get_tree().get_nodes_in_group("powerup_spawners")
		var closest_spawner = null
		var shortest_dist = INF
		for spawner in p_spawners:
			var dist_to = player.position.distance_to(spawner.position)
			if dist_to < shortest_dist and spawner.get_child_count() == 0:
				closest_spawner = spawner
				shortest_dist = dist_to
		if closest_spawner:
			closest_spawner.spawn_powerup()

func apply_consequences():
	is_active = false
	current_patient.bed.on_patient_removed()
	if current_patient:
		particle_emission(current_patient.global_position, current_patient.global_rotation, 0)
		var patient_node = current_patient as Node
		patient_node.queue_free()
	var failure = $Failure as AudioStreamPlayer
	failure.play()
	player.adjust_score(-10)
	clear_textures()
	SignalBus.cop_is_spawning.emit()
	
func clear_textures():
	for icon in $HBoxContainer.get_children():
			var icon_tex_rect = icon as TextureRect
			icon_tex_rect.texture = null

# Function to be called to spawn one-time emission of blood splat.			
func particle_emission(patient_pos, patient_rot, type):
	var particle = funnyParticle.instantiate()
	if type == 0:
		particle = deathParticle.instantiate()
	particle.position = patient_pos
	particle.rotation = patient_rot
	particle.emitting = true 
	get_tree().current_scene.add_child(particle)
