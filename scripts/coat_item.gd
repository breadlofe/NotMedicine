extends "res://scripts/item.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func pickup():
	super.pickup()
	get_parent().queue_free.call_deferred()
	SignalBus.on_pickup.emit(ItemTypes.ItemTypes.DOCTORS_OUTFIT)
