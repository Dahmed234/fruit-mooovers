extends TileMapLayer

signal tile_update

var is_changed = false

# Load in the wall layers, these need to be marked as un-navigatable
@onready var low_walls: TileMapLayer = $"../Low Walls"
@onready var destructible_walls: TileMapLayer = $"../Destructible walls"
@onready var high_walls: TileMapLayer = $"../High Walls"

# Load plant layers, spawn item spawners here
@onready var small_plants: TileMapLayer = $"../Small Plants"
@onready var medium_plants: TileMapLayer = $"../Medium Plants"
@onready var big_plants: TileMapLayer = $"../Big Plants"

# Objects to spawn in over tilemap
@export var wall: PackedScene
@export var destructableItem: PackedScene
@export var plantSpawner: PackedScene

const PLANT_STATS = {
	small	= [100,2,1],
	medium	= [500,5,5],
	large	= [1000,10,20]
}

func _ready() -> void:
	pass
func makePlantSpawner(size: String,coords: Vector2i):
	var n_spawner = plantSpawner.instantiate()
	n_spawner.global_position = to_global(map_to_local(coords))
	n_spawner.value = PLANT_STATS[size][0]
	n_spawner.followerValue = PLANT_STATS[size][1]
	n_spawner.weight = PLANT_STATS[size][2]
	get_parent().get_parent().add_child(n_spawner)

var first_time = true

func tiledataUpdate(coords,id):
	for layer in [small_plants,medium_plants,big_plants]:
		if coords in layer.get_used_cells_by_id(id):
			
			if first_time:
				
				
				#Set the "throwables" collision layer to true if this is a high wall
				match (layer):
					small_plants: 	makePlantSpawner("small",coords)
					medium_plants:	makePlantSpawner("medium",coords)
					big_plants:		makePlantSpawner("large",coords)
				
	# Check if any of the wall layers overlap with this tile
	for layer in [low_walls,high_walls]:
		if coords in layer.get_used_cells_by_id(id):
			if first_time:
				var n_wall = wall.instantiate()
				n_wall.global_position = to_global(map_to_local(coords))
				
				#Set the "throwables" collision layer to true if this is a high wall
				if layer == high_walls:  n_wall.collision_layer += 2 
				
				get_parent().get_parent().add_wall(n_wall)
			is_changed = true
			return true
	if coords in destructible_walls.get_used_cells_by_id(id):
		
		if first_time:
			# If this breaks, it means weight is undefined for the destructible_walls layer
			var weight = destructible_walls.get_cell_tile_data(coords).get_custom_data("Weight")
			if !weight: return false
			var n_wall = destructableItem.instantiate()
			n_wall.global_position = to_global(map_to_local(coords))
			n_wall.tilePos = coords
			n_wall.tileMap = destructible_walls
			n_wall.navMap = self
			n_wall.weight = weight
			get_parent().get_parent().add_wall(n_wall)
		is_changed = true
		return true

#@export var navPolygon: NavigationPolygon
# Code for fixing navigation for wall layers: https://www.youtube.com/watch?v=7ZAF_fn3VOc
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	tiledataUpdate(coords,0)
	
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
		
