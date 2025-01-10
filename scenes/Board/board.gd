class_name Board
extends GridContainer

@export var rows: int
@export var cols: int
@export var tile_textures: TileTextures
@export var max_mines: int = 10

var current_mines = 0
var game_started := false

func _ready() -> void:
	columns = cols
	Events.tile_pressed.connect(_on_tile_pressed)
	generate_board_base()


func generate_board_base() -> void:
	var total_tiles = rows * cols
	for _t in total_tiles:
		add_tile()


func generate_board_mines() -> void:
	# Calculate a fairly even chance for bombs on any given tile
	var mine_chance: float = float(max_mines) / float(rows * cols)
	# Loop through all tiles and randomly add mines until no more mines can be added
	while current_mines < max_mines:
		for tile in get_children():
			assert(tile is Tile, "generate_board_mines() encountered invalid child of board")
			if current_mines >= max_mines:
				break
			elif not tile.is_hidden:	# Skip unhidden tiles (usually initial tile)
				continue
			elif randf() <= mine_chance:
				current_mines += 1
				tile.state = Tile.State.MINE


func add_tile() -> void:
	var new_tile = Tile.new()
	new_tile.set_textures(tile_textures)
	add_child(new_tile)


func _on_tile_pressed(tile: Tile, _button: MouseButton) -> void:
	if not game_started:
		if not tile.is_hidden:	# If player is just marking flags, don't start game yet
			game_started = true
			generate_board_mines()
			return
