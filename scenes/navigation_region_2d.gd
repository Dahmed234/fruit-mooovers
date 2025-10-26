extends NavigationRegion2D


func rebake():
	print("rebaking")
	
	#navigation_polygon = null  # triggers rebuild
	
	bake_navigation_polygon(true)
	
func _ready() -> void:
	pass

func _on_navigation_tile_update() -> void:
	rebake()



func _on_baking_done() -> void:
	print("should be baked now!")
