extends NavigationRegion2D
@onready var navMap: TileMapLayer = $"../TileMap/Ground"


func rebake():
	bake_navigation_polygon(true)
	print("rebaking")
	
func _ready() -> void:
	#navMap.notify_runtime_tile_data_update()
	pass


# Maybe add a queue to handle rebaking multiple per tick?
func _on_baking_done() -> void:
	print("rebaked")
	


func _on_tile_update() -> void:
	rebake()
