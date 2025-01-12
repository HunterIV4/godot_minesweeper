### MINESWEEPER Godot 4.3 example - original by Awf Ibrahim (@awfyboy)
### Updated and refactored by HunterIV4
class_name Game
extends Node

# node references
@onready var mine_counter: Label = %MineCounter
@onready var time_elapsed: Label = %TimeElapsed
@onready var message: Label = %Message
@onready var timer: Timer = %GameTimer
@onready var row_counter: Label = %RowCounter
@onready var column_counter: Label = %ColumnCounter
@onready var max_mine_counter: Label = %MaxMineCounter
@onready var row_slider: HSlider = %RowSlider
@onready var column_slider: HSlider = %ColumnSlider
@onready var mine_slider: HSlider = %MineSlider
@onready var board: Board = %Board

@export var total_rows: int = 12
@export var total_columns: int = 8
@export var total_mines: int = 20

var minutes: int = 0
var seconds: int = 0


# return the size of the viewport
func get_viewport_size() -> Vector2:
	return get_viewport().get_visible_rect().size


func update_mine_guess_counter() -> void:
	mine_counter.text = "Mines: %s" % board.get_flagged_mine_count()


func update_row_custom_counter(value: int) -> void:
	row_counter.text = "Rows: %s" % value


func update_column_custom_counter(value: int) -> void:
	column_counter.text = "Columns: %s" % value


func update_mine_custom_counter(value: int) -> void:
	max_mine_counter.text = "Mines: %s" % value


# clear the grid and create new game
func reset_game() -> void:
	## reset default values
	minutes = 0
	seconds = 0
	timer.stop()
	board.reset()
	update_mine_guess_counter()
	message.hide()

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
	time_elapsed.text = "Time: %02d:%02d" % [minutes, seconds]


func _on_easy_pressed() -> void:
	total_rows = 10
	total_columns = 10
	total_mines = 12
	#generate_tiles(total_rows, total_columns, total_mines)


func _on_normal_pressed() -> void:
	total_rows = 16
	total_columns = 12
	total_mines = 25
	#generate_tiles(total_rows, total_columns, total_mines)


func _on_hard_pressed() -> void:
	total_rows = 18
	total_columns = 16
	total_mines = 40
	#generate_tiles(total_rows, total_columns, total_mines)


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
