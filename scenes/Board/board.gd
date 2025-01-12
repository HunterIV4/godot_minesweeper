class_name Board
extends GridContainer

@export var rows: int
@export var cols: int
@export var tile_textures: TileTextures
@export var max_mines: int = 10

var _current_mines = 0
var _flagged_mines = 0
var _game_started := false

func _ready() -> void:
	Events.tile_pressed.connect(_on_tile_pressed)
	Events.board_updated.connect(_on_board_updated)
	reset()


func get_flagged_mine_count() -> int:
	return _flagged_mines


func generate_board_base() -> void:
	var total_tiles = rows * cols
	for y in rows:
		for x in cols:
			add_tile(x, y)


func add_tile(x: int, y: int) -> void:
	var new_tile = Tile.new()
	new_tile.set_textures(tile_textures)
	new_tile.set_grid_position(Vector2(x, y))
	add_child(new_tile)


func count_flagged_and_reveal_all_mines() -> int:
	var mine_flagged_count:int = 0
	
	for tile in get_children():
		assert(tile is Tile, "count_flagged_and_reveal_all_mines() encountered invalid child of board")
		if tile.is_hidden:
			if tile.reveal():
				if tile.is_flagged:
					mine_flagged_count += 1
	return mine_flagged_count


func generate_board_mines() -> void:
	# Calculate a fairly even chance for bombs on any given tile
	var mine_chance: float = float(max_mines) / float(rows * cols)
	var mined_tiles: Array[Tile] = []
	
	# Loop through all tiles and randomly add mines until no more mines can be added
	while _current_mines < max_mines:
		for tile in get_children():
			assert(tile is Tile, "generate_board_mines() encountered invalid child of board")
			if _current_mines >= max_mines:
				break
			elif not tile.is_hidden:	# Skip unhidden tiles (usually initial tile)
				continue
			elif randf() <= mine_chance:
				_current_mines += 1
				tile.state = Tile.State.MINE
				mined_tiles.append(tile)
	
	for tile in get_children():
		if tile.state != Tile.State.MINE:
			var mines_nearby := _count_adjacent_mines(tile, mined_tiles)
			tile.set_mines_nearby(mines_nearby)


func reset() -> void:
	columns = cols
	_current_mines = 0
	_flagged_mines = 0
	# Clear existing board if needed
	for tile in get_children():
		tile.queue_free()
	
	generate_board_base()


func check_win() -> bool:
	for tile in get_children():
		# If the tile isn't revealed and is both a flagged tile that is a mine,
		# continue checking, otherwise it's not a win
		if tile.hidden and not (tile.is_flagged and tile.state != Tile.State.MINE):
			return false
	return true

func _count_adjacent_mines(tile: Tile, mined_tiles: Array[Tile]) -> int:
	var count = 0
	for neighbor in _get_neighbors(tile):
		if mined_tiles.has(neighbor):
			count += 1
	return count


func _get_neighbors(tile: Tile) -> Array[Tile]:
	var neighbors: Array[Tile] = []
	var directions = [
		Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
		Vector2(-1,  0),                 Vector2(1,  0),
		Vector2(-1,  1), Vector2(0,  1), Vector2(1,  1)
	]
	for dir in directions:
		var neighbor_pos = tile.grid_position + dir
		var neighbor = get_tile_at_position(neighbor_pos)
		if neighbor:
			neighbors.append(neighbor)
	return neighbors


func get_tile_at_position(pos: Vector2) -> Tile:
	for tile in get_children():
		if tile.grid_position == pos:
			return tile
	return null


func _reveal_neighbors(tile: Tile) -> void:
	var neighbors = _get_neighbors(tile)
	
	for neighbor in neighbors:
		if neighbor.is_hidden:
			neighbor.reveal()
			
			if neighbor.state == Tile.State.SAFE:
				_reveal_neighbors(neighbor)


func _on_tile_pressed(tile: Tile, button: MouseButton) -> void:
	# Check for initial game setup
	if not _game_started:
		if not tile.is_hidden:	# If player is just marking flags, don't start game yet
			_game_started = true
			generate_board_mines()
	
	# Player revealed tile
	if not tile.is_hidden:
		if tile.state == Tile.State.MINE:
			Events.mine_revealed.emit(tile)
		elif tile.state == Tile.State.SAFE:
			_reveal_neighbors(tile)


func _on_board_updated(new_rows: int, new_cols: int, new_mines: int):
	# Set new dimensions and recreate board
	rows = new_rows
	cols = new_cols
	max_mines = new_mines
	reset()
