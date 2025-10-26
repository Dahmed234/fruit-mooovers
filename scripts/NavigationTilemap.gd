extends TileMapLayer

signal tile_update

var is_changed = false

# Load in the wall layers, these need to be marked as un-navigatable
@onready var low_walls: TileMapLayer = $"../Low Walls"
@onready var destructible_walls: TileMapLayer = $"../Destructible walls"
@onready var high_walls: TileMapLayer = $"../High Walls"
@export var wall: PackedScene
@export var destructableItem: PackedScene

#@export var navPolygon: NavigationPolygon
# Code for fixing navigation for wall layers: https://www.youtube.com/watch?v=7ZAF_fn3VOc
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	# Check if any of the wall layers overlap with this tile
	for layer in [low_walls,high_walls]:
		if coords in layer.get_used_cells_by_id(1):
			var n_wall = wall.instantiate()
			n_wall.global_position = to_global(map_to_local(coords)) + Vector2(8,8)
			get_parent().get_parent().add_wall(n_wall)
			is_changed = true
			return true
	if coords in destructible_walls.get_used_cells_by_id(1):
		var n_wall = destructableItem.instantiate()
		n_wall.global_position = to_global(map_to_local(coords)) + Vector2(3,3)
		n_wall.tilePos = coords
		n_wall.tileMap = destructible_walls
		get_parent().get_parent().add_wall(n_wall)
		is_changed = true
		return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	pass
	#for layer in [low_walls,high_walls]:
		#if coords in layer.get_used_cells_by_id(1):
			#tile_data.set_navigation_polygon(0, null)
	#if coords in destructible_walls.get_used_cells_by_id(1):
		#tile_data.set_navigation_polygon(0, null)
	#else:
		#tile_data.set_navigation_polygon(0, tile_data.get_navigation_polygon(0))
func _process(delta: float) -> void:
	if is_changed:
		is_changed = false
		tile_update.emit()
		
