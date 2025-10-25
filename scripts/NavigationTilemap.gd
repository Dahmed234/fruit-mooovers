extends TileMapLayer

# Load in the wall layers, these need to be marked as un-navigatable
@onready var low_walls: TileMapLayer = $"../Low Walls"
@onready var destructible_walls: TileMapLayer = $"../Destructible walls"
@onready var high_walls: TileMapLayer = $"../High Walls"

var to_update_nav := false

@export var navPolygon: NavigationPolygon
# Code for fixing navigation for wall layers: https://www.youtube.com/watch?v=7ZAF_fn3VOc
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	# Check if any of the wall layers overlap with this tile
	for layer in [low_walls,destructible_walls,high_walls]:
		if coords in layer.get_used_cells_by_id(1):
			return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	for layer in [low_walls,high_walls]:
		if coords in layer.get_used_cells_by_id(1):
			tile_data.set_navigation_polygon(0, null)
	if coords in destructible_walls.get_used_cells_by_id(1):
		tile_data.set_navigation_polygon(0, null)
	else:
		tile_data.set_navigation_polygon(0, navPolygon)
		to_update_nav = true

func _process(delta: float) -> void:
	pass
	#if to_update_nav:
	#	call_deferred("notify_runtime_tile_data_update")
	#	to_update_nav = false
