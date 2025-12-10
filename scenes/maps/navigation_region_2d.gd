extends NavigationRegion2D
@onready var navMap: TileMapLayer = $"Ground"



@export
var cachedMap :NavigationMeshSourceGeometryData2D
func rebake():
	bake_navigation_polygon(true)
	
func _ready() -> void:
	get_tree().get_nodes_in_group("destroyableWall").map(func(i) :
			#i.requestDestroy.connect(_on_object_destroyed))
			pass)

	#navMap.notify_runtime_tile_data_update()
	pass


func _on_object_destroyed(wall :Node2D):
	wall.queue_free()
	
	await get_tree().physics_frame
	rebake()
	
	print("destroyed")


# Maybe add a queue to handle rebaking multiple per tick?
func _on_baking_done() -> void:
	pass


func _on_tile_update() -> void:
	rebake()
 
