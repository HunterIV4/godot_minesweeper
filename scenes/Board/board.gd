class_name Board
extends GridContainer

@export var rows: int
@export var cols: int
@export var tile_textures: TileTextures

func _ready() -> void:
	columns = cols
	generate_board_base()

func generate_board_base() -> void:
	var total_tiles = rows * cols
	for _t in total_tiles:
		add_tile()

func add_tile():
	var new_tile = Tile.new()
	new_tile.set_textures(tile_textures)
	add_child(new_tile)
