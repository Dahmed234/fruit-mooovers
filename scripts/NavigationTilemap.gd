extends TileMapLayer

signal tile_update

var is_changed = false

@onready var root: Node2D = $"../.."

# Load in the wall layers, these need to be marked as un-navigatable
@onready var low_walls: TileMapLayer = $"../Walls"
@onready var destructible_walls: TileMapLayer = $"../Destructible walls"
# Load plant layer, spawn item spawners here
@onready var plants: TileMapLayer = $"../Plants"

# Objects to spawn in over tilemap
@export var wall: PackedScene
@export var destructableItem: PackedScene
@export var plantSpawner: PackedScene

	

var first_time = true

			
#@export var navPolygon: NavigationPolygon
# Code for fixing navigation for wall layers: https://www.youtube.com/watch?v=7ZAF_fn3VOc
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	# Check if any of the wall layers overlap with this tile
	for layer in [low_walls,destructible_walls,plants]:
		if coords in layer.get_used_cells_by_id(0):
			if first_time:
				match layer:
					#low_walls,high_walls:
						#var n_wall = wall.instantiate()
						#n_wall.global_position = to_global(map_to_local(coords))
						
						#Set the "throwables" collision layer to true if this is a high wall
						#if layer == high_walls:  n_wall.collision_layer += 2 
						
						#get_parent().get_parent().add_wall(n_wall)
						
					plants:
						var n_spawner = plantSpawner.instantiate()
						n_spawner.global_position = to_global(map_to_local(coords))
						var value = plants.get_cell_tile_data(coords).get_custom_data("Value")
						var followerValue = plants.get_cell_tile_data(coords).get_custom_data("Follower Value")
						var weight = plants.get_cell_tile_data(coords).get_custom_data("Weight")
						var sprite = plants.get_cell_tile_data(coords).get_custom_data("Sprite")
						
						n_spawner.value = value
						n_spawner.followerValue = followerValue
						n_spawner.weight = weight
						n_spawner.sprite = sprite
						root.add_child(n_spawner)
					destructible_walls:
						# If this breaks, it means weight is undefined for the destructible_walls layer
						var value = destructible_walls.get_cell_tile_data(coords).get_custom_data("Value")
						var followerValue = destructible_walls.get_cell_tile_data(coords).get_custom_data("Follower Value")
						var weight = destructible_walls.get_cell_tile_data(coords).get_custom_data("Weight")
						if !weight: return false
						var n_wall = destructableItem.instantiate()
						n_wall.global_position = to_global(map_to_local(coords))
						n_wall.tilePos = coords
						n_wall.tileMap = destructible_walls
						n_wall.navMap = self
						n_wall.value = value
						n_wall.followerValue = followerValue
						n_wall.weight = weight
						root.add_wall(n_wall)
	is_changed = true
	
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
		first_time = false
		is_changed = false
		tile_update.emit()
		
