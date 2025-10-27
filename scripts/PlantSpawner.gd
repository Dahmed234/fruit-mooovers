extends Node2D

@export
var item: PackedScene

var value: float
var followerValue: float
var weight: float

var currentItem

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	spawn()

func spawn():
	if !currentItem:
		var nItem = item.instantiate()
		currentItem = nItem
		nItem.value = value
		nItem.followerValue = followerValue
		nItem.weight = weight
		nItem.global_position = global_position
		get_parent().add_child(nItem)
