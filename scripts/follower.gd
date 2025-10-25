extends CharacterBody2D

class_name Follower
const scene :PackedScene = preload("res://prefabs/Follower.tscn")

signal carryFinished(item :Carryable)
signal carryDropped(item: ItemData)

var currentItem :StaticBody2D = null

@export
var BASESPEED = 100

@export
var label: Label

# variables that effect the followers wander state
var currentspeed = BASESPEED
var SPEEDVARIANCE = 40

# how long character moves in a direction for before wandering
var TIMERLENGTH =0.5
var TIMERVARIANCE =0.1

#
var direction := Vector2.ONE

# How detectible are followers to enemy units
const enemy_weight := 0.2

var currentState = State.FOLLOW

@onready var timer := $WanderTimer
@onready var navAgent := $NavigationAgent2D

# possible states follower can be in
enum State {
	INITIAL,
	CARRYING,
	WANDER,
	FOLLOW,
	IDLE
}

func canBeThrown():
	
	match currentState:
		State.FOLLOW: return true
		State.IDLE: return true
		State.WANDER: return true
		State.INITIAL: return false
		State.CARRYING: return false

func onWhistle():
	match currentState:
		State.CARRYING:
			stopCarrying()
		State.WANDER:
			endWander()
			startFollow()

# initialises a new follower with given parameters
static func newFollower(pos,startingState: State):
	var follower :Follower = scene.instantiate()
	
	follower.currentState = startingState
	follower.global_position = pos
	# Add follower to the enemy target list
	return follower

func startWander():
	currentState = State.WANDER
	on_timeout()

func _ready() -> void:
	$heldItem/Sprite.texture = null
	label.hide()
	
	#need to wait for all physics components to load in
	# idk why exactly but DO NOT TOUCH THESE OR CARRYING WILL BREAK
	await get_tree().physics_frame
	await get_tree().physics_frame

	match currentState:
		# decide what to do based on surroundings
		State.INITIAL:
			
			#test to see if items are nearby
			# get all nearby items

			var nearbyLoot   = $viewRadius.get_overlapping_areas()
			nearbyLoot = nearbyLoot.filter(func(item): return item.get_parent() is Carryable)
			if(!nearbyLoot.is_empty()):
				var obtainedItem :Carryable = nearbyLoot.pop_back().get_parent()
				currentItem = obtainedItem
				#currentItem.followersCarrying += 1
				startCarry(obtainedItem)
			else:
				startWander()
		State.WANDER:
			startWander()
		State.FOLLOW:
			startFollow()
		State.IDLE:
			startIdle()

func startCarry(item : Carryable):
	
	#setup sprite
	currentState = State.CARRYING
	var currentSprite = $heldItem/Sprite
	var newSprite = item.getSpriteInfo()
	currentSprite.texture = newSprite.texture
	currentSprite.region_rect = newSprite.region_rect
	currentSprite.region_enabled = newSprite.region_enabled
	currentSprite.transform = newSprite.transform
	
	currentItem = item
	
	# Ensure the follower snaps to the item so it doesn't move when picked up
	global_position = item.global_position
	
	item.onPickup(self)
	
	if currentItem.followersCarrying.size() > 1:
		hide()
	
	navAgent.target_position = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map,4,true)

func stopCarrying():
	if !(currentState == State.CARRYING):
		return
	$heldItem.hide()
	velocity = Vector2.ZERO
	currentItem.onDrop(self)
	currentItem = null
	show()
	startWander()


# for navigation: need to wait for first physics frame
func actor_setup():
	await get_tree().physics_frame

func _physics_process(delta: float) -> void:
	match currentState:
		State.IDLE:
			label.hide()
			
			# triggers if follower is close enough to an area on a specific layer
			# uses specific collision layer to only detect player follower
			if(!$viewRadius.has_overlapping_areas()) :
				startFollow()

		State.WANDER:
			label.hide()
			velocity = velocity.slerp(0.4* currentspeed * direction, 0.1) 

		State.CARRYING:
			label.show()
			label.text = str(int(currentItem.followersCarrying.size())) + "/" + str(int(currentItem.weight))
			if navAgent.is_target_reached():
				var tmp = currentItem
				for cow in currentItem.followersCarrying.keys():
					cow.stopCarrying()
				
				carryFinished.emit(tmp,position)

			else:
				var next_path_position :Vector2 = navAgent.get_next_path_position()
				var local_velocity = 0.0
				if currentItem.followersCarrying.size() >= currentItem.weight:
					# Set the speed that the object will be moved,this will be between 10% and 40% of regular speed depending on 
					# How many cows are used
					local_velocity = 0.2 * min(2.0,currentItem.followersCarrying.size() / currentItem.weight / 2.0)
				velocity = global_position.direction_to(next_path_position) * BASESPEED * local_velocity
		State.FOLLOW:
			if navAgent.is_target_reached():
				startIdle()
			else:
				var newGoal = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map,2,false)
				if(navAgent.target_position.distance_to(newGoal) > CHANGEDIRECTIONDISTANCE):
						navAgent.target_position = newGoal
				
				var next_path_position :Vector2 = navAgent.get_next_path_position()
				velocity = global_position.direction_to(next_path_position) * BASESPEED

	move_and_slide()



const CHANGEDIRECTIONDISTANCE = 150.0 
#initialises states to idle
func startIdle():
	currentState = State.IDLE
	velocity = Vector2.ZERO

#initialises state to follow
func startFollow():
	currentState = State.FOLLOW
	
	#use 4 as layer number as it is value for home point
	navAgent.target_position = NavigationServer2D.map_get_random_point(get_world_2d().navigation_map,2,true)

func endWander():
	direction= Vector2.ZERO
	timer.stop()
	

#used for wander, picks random direction for character to wander to next
func on_timeout() -> void:
	#pick a random direction
	var oldDirection := Vector2(direction)
	
	direction.x = randf_range(-1,1)
	direction.y = randf_range(-1,1)
	direction = direction.normalized()
	
	direction.lerp(oldDirection, randf())	
	currentspeed = BASESPEED + SPEEDVARIANCE * randf_range(-1,1)
		#start timer again
	timer.start(TIMERLENGTH + TIMERVARIANCE * randf_range(-1,1))
