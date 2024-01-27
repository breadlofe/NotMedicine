extends "res://scripts/item.gd"

@export var texture: Texture2D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pickup():
	super.pickup()
	get_parent().queue_free.call_deferred()
	SignalBus.on_pickup.emit(ItemTypes.ItemTypes.SUPERSTAR)
	
