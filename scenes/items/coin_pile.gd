extends CollisionShape2D



@onready
var bounds := shape.get_rect()

var coin_scene = preload("res://scenes/items/fruits/coin.tscn")

@export
var num_coins = 5

var distance = 20

var coin_points :Array[Vector2]


func get_random_point() -> Vector2:
	
	
	var x =randf_range(bounds.position.x,bounds.end.x)
	var y = randf_range(bounds.position.y,bounds.end.y)
	
	return Vector2(x,y)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.hide()
	
	for i in num_coins:
		for j in 100:
			if j == 99: break
			var random = get_random_point()
			if(coin_points\
			.filter(func(i :Vector2): return i.distance_to(random) <distance))\
			.is_empty():
					coin_points.append(random)
					var new_coin :Node2D = coin_scene.instantiate() 
					new_coin.global_position = random
					add_child(new_coin)
					break
					
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
