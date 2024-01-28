extends "res://scripts/item.gd"


func pickup():
	super.pickup()
	get_parent().queue_free.call_deferred()
	SignalBus.on_pickup.emit(ItemTypes.ItemTypes.CLOWN_HORN)
