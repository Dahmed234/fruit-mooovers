extends Resource

class_name ItemData

enum ItemSprites{
	APPLE,
	BANANA,
	CHOCOLATE,
	MANGO
}
	



@export 
var spriteID :ItemSprites



# Points rewarded by the item
@export
var value :int

@export 
var followerValue :int

@export 
var minimum_followers :int

#func _init(p_value = 0, p_followerValue = 0,p_minimum_followers = 0):
	#value =p_value
	#followerValue = p_followerValue
	#minimum_followers = p_minimum_followers
	#followersCarrying = 0.0
