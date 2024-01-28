extends CanvasLayer

@export var textures: Array[CompressedTexture2D]

# Packed scene for particle emissions.
@export var deathParticle: PackedScene

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

			if(keycode != event.keycode):
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
	clear_textures()

func apply_consequences():
	is_active = false
	if current_patient:
		explode_blood(current_patient.global_position, current_patient.global_rotation)
		var patient_node = current_patient as Node
		patient_node.queue_free()
	clear_textures()
	
func clear_textures():
	for icon in $HBoxContainer.get_children():
			var icon_tex_rect = icon as TextureRect
			icon_tex_rect.texture = null

# Function to be called to spawn one-time emission of blood splat.			
func explode_blood(patient_pos, patient_rot):
	var blood_particle = deathParticle.instantiate()
	blood_particle.position = patient_pos
	blood_particle.rotation = patient_rot
	blood_particle.emitting = true 
	get_tree().current_scene.add_child(blood_particle)
