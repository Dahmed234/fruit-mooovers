extends NavigationRegion2D


func rebake():
	bake_navigation_polygon(true)
	
func _ready() -> void:
	pass

func _on_navigation_tile_update() -> void:
	rebake()


# Maybe add a queue to handle rebaking multiple per tick?
func _on_baking_done() -> void:
	pass
