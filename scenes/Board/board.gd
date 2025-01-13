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
	Events.mine_revealed.connect(_on_mine_revealed)
	reset() # Set to initial state

#region Utility
func enable_tiles() -> void:
	for tile in get_children():
		tile.enable_input()


func disable_tiles() -> void:
	for tile in get_children():
		tile.disable_input()


func get_flagged_mine_count() -> int:
	return _flagged_mines
#endregion

#region Board Generation
func generate_board_base() -> void:
	# While the board uses a grid, get_children() returns a 1D array
	# Each tile keeps track of its x, y coordinates to make
	# handling the grid easier.
	var total_tiles = rows * cols
	for y in rows:
		for x in cols:
			add_tile(x, y)


func add_tile(x: int, y: int) -> void:
	var new_tile = Tile.new()
	new_tile.set_textures(tile_textures)
	new_tile.set_grid_position(Vector2(x, y))
	add_child(new_tile)


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
			# The randf() function generates a float from 0 to 1,
			# checking if the number is less than or equal to is
			# equivalent to percent chance
			elif randf() <= mine_chance:
				_current_mines += 1
				tile.set_state_mine()
				mined_tiles.append(tile)
	
	# Go through again and set caution states after mines have been generated
	for tile in get_children():
		if not tile.is_mine():
			var mines_nearby := _count_adjacent_mines(tile, mined_tiles)
			tile.set_mines_nearby(mines_nearby)


func _count_adjacent_mines(tile: Tile, mined_tiles: Array[Tile]) -> int:
	# Helper function to determine caution states
	var count = 0
	for neighbor in _get_neighbors(tile):
		if mined_tiles.has(neighbor):
			count += 1
	return count


func _get_neighbors(tile: Tile) -> Array[Tile]:
	# Returns an array of all tiles that are neighbors of
	# the specified tile. Direction specifies 8 options, but
	# not all tiles will have 8 neighbors. The reason this
	# works is because invalid positions (indexes outside
	# the size of the grid) will simply return null,
	# which is ignored.
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
	# Null state means the position does not exist on the board
	for tile in get_children():
		if tile.grid_position == pos:
			return tile
	return null
#endregion

#region Game End
func reveal_mines() -> void:
	# Reveals all mines, used for game end, to show
	# user how the board looked.
	for tile in get_children():
		if tile.is_hidden and tile.is_mine():
			tile.reveal()


func count_flagged_mines() -> int:
	# Checks specifically for mines that are properly
	# flagged. This may be different from total number
	# of flags.
	var mine_flagged_count:int = 0
	for tile in get_children():
		assert(tile is Tile, "count_flagged_and_reveal_all_mines() encountered invalid child of board")
		if tile.is_hidden:
			if tile.is_mine():
				if tile.is_flagged:
					mine_flagged_count += 1
	return mine_flagged_count


func all_hidden_clear() -> bool:
	# Used to check if everything except flagged tiles are revealed.
	# Useful for determining if the game is finished.
	for tile in get_children():
	# Flagged are still considered hidden but don't count for game end
		if tile.is_hidden and not tile.is_flagged:
			return false
	return true


func reset() -> void:
	_game_started = false
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
		if tile.hidden and not (tile.is_flagged and not tile.is_mine()):
			return false
	return true


func _on_mine_revealed() -> void:
	var correctly_flagged = count_flagged_mines()
	reveal_mines()
	Events.game_ended.emit(correctly_flagged, max_mines)
#endregion

#region State Update
func _reveal_neighbors(tile: Tile) -> void:
	# Recursive helper function used to reveal all connected safe tiles.
	var neighbors = _get_neighbors(tile)
	
	for neighbor in neighbors:
		if neighbor.is_hidden:
			neighbor.reveal()
			
			if neighbor.is_safe():
				_reveal_neighbors(neighbor)


func _on_tile_pressed(tile: Tile, button: MouseButton) -> void:
	# Check for initial game setup
	if not _game_started:
		if not tile.is_hidden:	# If player is just marking flags, don't start game yet
			_game_started = true
			generate_board_mines()
		else:
			tile.set_flag_state(false)
	
	# Player revealed tile
	if not tile.is_hidden:
		if tile.is_flagged:
			tile.is_flagged = false
			_flagged_mines -= 1
			Events.tile_flagged.emit()
		if tile.is_mine():
			Events.mine_revealed.emit(tile)
		elif tile.is_safe():
			_reveal_neighbors(tile)
	
	# Player flagged or unflagged tile
	elif _game_started and button == MOUSE_BUTTON_RIGHT:
		if tile.is_flagged:
			_flagged_mines += 1
			Events.tile_flagged.emit()
		else:
			_flagged_mines -= 1
			assert(_flagged_mines >= 0, "_on_tile_pressed caused _flagged mines to go below 0")
			Events.tile_flagged.emit()
	
	# Check for game end:
	if _flagged_mines == max_mines and all_hidden_clear():
		Events.game_ended.emit(count_flagged_mines(), max_mines)

func _on_board_updated(new_rows: int, new_cols: int, new_mines: int):
	# Set new dimensions and recreate board
	rows = new_rows
	cols = new_cols
	max_mines = new_mines
	reset()
#endregion
