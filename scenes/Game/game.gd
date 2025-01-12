### MINESWEEPER Godot 4.3 example - by Awf Ibrahim (@awfyboy)
extends Node

# states for the tiles
enum states {SAFE, CAUTION, MINE}

# texture resources
const CAUTION_1 = preload("res://sprites/1.png")
const CAUTION_2 = preload("res://sprites/2.png")
const CAUTION_3 = preload("res://sprites/3.png")
const CAUTION_4 = preload("res://sprites/4.png")
const CAUTION_5 = preload("res://sprites/5.png")
const CAUTION_6 = preload("res://sprites/6.png")
const CAUTION_7 = preload("res://sprites/7.png")
const CAUTION_8 = preload("res://sprites/8.png")
const MINE = preload("res://sprites/mine.png")
const MINE_SELECTED = preload("res://sprites/mine_selected.png")
const FLAG = preload("res://sprites/flag.png")
const HIDDEN = preload("res://sprites/hidden.png")
const SAFE = preload("res://sprites/safe.png")

# node references
@onready var mine_counter: Label = $Control/MineCounter
@onready var time_elapsed: Label = $Control/TimeElapsed
@onready var message: Label = $Control/Message
@onready var timer: Timer = $Timer
@onready var row_counter: Label = $Control/RowCounter
@onready var column_counter: Label = $Control/ColumnCounter
@onready var mine_counter_2: Label = $Control/MineCounter2
@onready var row_slider: HSlider = $Control/RowSlider
@onready var column_slider: HSlider = $Control/ColumnSlider
@onready var mine_slider: HSlider = $Control/MineSlider

# game related values
const TILE = preload("res://scenes/Tile/tile.tscn")
const GRID_SIZE: int = 32

@export var total_rows: int = 12
@export var total_columns: int = 8
@export var total_mines: int = 20

# I'm using a 1D array (which is harder honestly) but you may adapt this to a 2D array
var grid: Array[Tile] = []

var is_first_click: bool = true
var can_click: bool = true
var minutes: int = 0
var seconds: int = 0

# used for user flagging tiles
var mine_guesses: int = 0


# return the size of the viewport
func get_viewport_size() -> Vector2:
	return get_viewport().get_visible_rect().size


# update the time elapsed counter
func update_time() -> void:
	time_elapsed.text = "Time: %02d:%02d" % [minutes, seconds]


# update mine counter
func update_mine_guess_counter() -> void:
	## if it is the first click, make the amount of mines hidden
	## this is done because, mines are generated only after the first click
	## so edge cases like mines > total tiles need to be checked
	if is_first_click:
		mine_counter.text = "Mines: ???"
	else:
		mine_counter.text = "Mines: %s" % mine_guesses


# update custom game's row counter
func update_row_custom_counter(value: int) -> void:
	row_counter.text = "Rows: %s" % value


# update custom game's column counter
func update_column_custom_counter(value: int) -> void:
	column_counter.text = "Columns: %s" % value


# update custom game's row counter
func update_mine_custom_counter(value: int) -> void:
	mine_counter_2.text = "Mines: %s" % value


# clear the grid and create new game
func reset_game() -> void:
	## reset default values
	is_first_click = true
	can_click = true
	minutes = 0
	seconds = 0
	mine_guesses = 0
	update_mine_guess_counter()
	message.hide()
	update_time()
	timer.start()
	
	## ensure that the grid isn't already empty before clearing
	if grid.size() > 0:
		for i in range(grid.size()):
			var tile: Tile = grid[i]
			tile.queue_free()
		grid.clear()


# create tiles inside of the grid
func generate_tiles(rows: int, columns: int, mines: int) -> void:
	## first, reset any existing grid
	reset_game()
	
	## add tiles to the root node and grid
	## the tile scenes are treated like abstract objects
	## they will have 'virtual positions' based on the grid
	## these positions are simply their index position on the grid array
	## columns for x-axis and rows for y-axis
	for y in range(rows):
		for x in range(columns):
			## calculate offsets for tile position
			var grid_width: int = GRID_SIZE * columns
			var grid_height: int = GRID_SIZE * rows
			var screen_width: int = get_viewport_size().x
			var screen_height: int = get_viewport_size().y
			var hor_offset: int = ((screen_width - grid_width)/2)
			var ver_offset: int = ((screen_height - grid_height)/2)
			
			## add new tile and set its position and virtual position
			var tile_pos: Vector2 = Vector2((GRID_SIZE * x) + hor_offset, (GRID_SIZE * y) + ver_offset)
			var virtual_pos: int = x + (y * columns)
			add_tile(tile_pos, virtual_pos, y, x)








# reveal all the mines in the grid
func reveal_mines() -> void:
	for tile in grid:
		if tile.state == states.MINE:
			tile.texture_normal = MINE
			tile.is_hidden = false


# check if the user has won
# this is done by checking if the remaining tiles are all mines
func check_win() -> bool:
	## get the remaining tiles
	var remaining_tiles: int = 0
	for tile in grid:
		if tile.is_hidden:
			remaining_tiles += 1
	
	## check if the remaining tiles and total mines are equal
	if remaining_tiles == total_mines:
		return true
	return false


# initialize new game at the start of program
func _ready() -> void:
	#Events.tile_pressed.connect(on_tile_pressed)
	
	## set custom game sliders to some default values
	row_slider.value = 11
	column_slider.value = 12
	mine_slider.value = 20
	update_row_custom_counter(row_slider.value)
	update_column_custom_counter(column_slider.value)
	update_mine_custom_counter(mine_slider.value)
	
	## start a new easy game
	_on_easy_pressed()


# call when a tile is pressed
#func on_tile_pressed(virtual_pos: int, mouse_button: int) -> void:
	### get the tile that was just pressed
	#var tile: Tile = grid[virtual_pos]
	#
	### check if the user can click
	#if can_click:
		### if right clicked, toggle the tile flagging
		#if mouse_button == MOUSE_BUTTON_RIGHT:
			#if tile.texture_normal == HIDDEN:
				#tile.texture_normal = FLAG
				#tile.is_flagged = true
				#mine_guesses -= 1
			#else:
				#tile.texture_normal = HIDDEN
				#tile.is_flagged = false
				#mine_guesses += 1
			#
			### update the mine guess counter so it reflets the amount of flags
			#update_mine_guess_counter()
		#
		### if left clicked, reveal the tile
		### ensure tile isn't flagged and the user can press tiles
		#elif mouse_button == MOUSE_BUTTON_LEFT and not tile.is_flagged:
			### if it is the first click, start assigning mines to the tiles
			### it is done here to ensure that the user's first click will never be a mine
			#if is_first_click:
				#assign_tiles(total_rows, total_columns, total_mines, tile)
				#is_first_click = false
			#
			### reveal this tile and any nearby tiles that are safe
			### repeat until it reaches a caution tile
			#reveal_nearby_tiles(tile)
			#
			### update the mine guess counter after a tile is pressed
			#update_mine_guess_counter()
			#
			### check if the user has won
			#if check_win():
				### flag the remaining tiles
				#for mine_tile in grid:
					#if mine_tile.is_hidden:
						#mine_tile.texture_normal = FLAG
						#mine_tile.is_flagged = true
				#
				#mine_guesses = 0
				#message.show()
				#message.text = "You Won!"
				#timer.stop()
				#can_click = false


func _on_timer_timeout() -> void:
	seconds += 1
	if seconds > 60:
		minutes += 1
		seconds = 0
	update_time()


func _on_easy_pressed() -> void:
	total_rows = 10
	total_columns = 10
	total_mines = 12
	generate_tiles(total_rows, total_columns, total_mines)


func _on_normal_pressed() -> void:
	total_rows = 16
	total_columns = 12
	total_mines = 25
	generate_tiles(total_rows, total_columns, total_mines)


func _on_hard_pressed() -> void:
	total_rows = 18
	total_columns = 16
	total_mines = 40
	generate_tiles(total_rows, total_columns, total_mines)


func _on_custom_game_pressed() -> void:
	total_rows = row_slider.value
	total_columns = column_slider.value
	total_mines = mine_slider.value
	generate_tiles(total_rows, total_columns, total_mines)


func _on_row_slider_value_changed(value: float) -> void:
	update_row_custom_counter(value)


func _on_column_slider_value_changed(value: float) -> void:
	update_column_custom_counter(value)


func _on_mine_slider_value_changed(value: float) -> void:
	update_mine_custom_counter(value)
