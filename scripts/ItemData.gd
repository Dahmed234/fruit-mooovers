extends Resource

class_name ItemData

@export
var value: int

@export
var followerValue: int

@export 
var weight: int
func _init(p_value = 0, p_followerValue = 0,p_weight = 0):
	value =p_value
	followerValue = p_followerValue
	weight = p_weight
