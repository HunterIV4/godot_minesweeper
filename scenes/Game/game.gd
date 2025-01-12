### MINESWEEPER Godot 4.3 example - original by Awf Ibrahim (@awfyboy)
### Updated and refactored by HunterIV4
class_name Game
extends Node

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
@onready var resign: Button = %Resign

@onready var main_game: Control = %MainGame
@onready var menu_options: Control = %MenuOptions

var minutes: int = 0
var seconds: int = 0


func _ready() -> void:
	Events.mine_revealed.connect(_on_mine_revealed)
	Events.tile_flagged.connect(_on_tile_flagged)
	Events.board_updated.emit(row_slider.value, column_slider.value, mine_slider.value)
	main_game.hide()
	
	row_slider.value = 11
	column_slider.value = 12
	mine_slider.value = 20
	update_row_custom_counter(row_slider.value)
	update_column_custom_counter(column_slider.value)
	update_mine_custom_counter(mine_slider.value)
	update_mine_guess_counter()


func update_mine_guess_counter() -> void:
	mine_counter.text = "Mines: %s" % (board.max_mines - board.get_flagged_mine_count())


func update_row_custom_counter(value: int) -> void:
	row_counter.text = "Rows: %s" % value


func update_column_custom_counter(value: int) -> void:
	column_counter.text = "Columns: %s" % value


func update_mine_custom_counter(value: int) -> void:
	max_mine_counter.text = "Mines: %s" % value


func reset_game() -> void:
	minutes = 0
	seconds = 0
	timer.stop()
	board.reset()
	update_mine_guess_counter()
	message.hide()


func _on_mine_revealed() -> void:
	timer.stop()
	menu_options.show()
	board.disable_tiles()
	var correctly_flagged := board.count_flagged_and_reveal_all_mines()
	
	message.text = "Game Over! You correctly identified %d mines out of %d. Play again?" % [correctly_flagged, board.max_mines]
	message.show()
	resign.hide()


func _on_tile_flagged() -> void:
	update_mine_guess_counter()
	
	# Game has ended if all mines have been marked
	if board.get_flagged_mine_count() == board.max_mines:
		timer.stop()
		menu_options.show()
		board.disable_tiles()
		var correctly_flagged := board.count_flagged_and_reveal_all_mines()
		if board.check_win():
			message.text = "You won! All mines were correctly identified. Play again?"
		else:
			message.text = "You lost! You missed %d mines." % (board.max_mines - correctly_flagged)
		message.show()
		resign.hide()


func _on_timer_timeout() -> void:
	seconds += 1
	if seconds > 60:
		minutes += 1
		seconds = 0
	time_elapsed.text = "Time: %02d:%02d" % [minutes, seconds]


func _on_easy_pressed() -> void:
	row_slider.value = 10
	column_slider.value = 10
	mine_slider.value = 12


func _on_normal_pressed() -> void:
	row_slider.value = 16
	column_slider.value = 12
	mine_slider.value = 25


func _on_hard_pressed() -> void:
	row_slider.value = 18
	column_slider.value = 16
	mine_slider.value = 40


func _on_start_game_pressed() -> void:
	Events.board_updated.emit(row_slider.value, column_slider.value, mine_slider.value)
	update_mine_guess_counter()
	main_game.show()
	resign.show()
	menu_options.hide()
	message.hide()
	timer.start()


func _on_row_slider_value_changed(value: float) -> void:
	update_row_custom_counter(value)


func _on_column_slider_value_changed(value: float) -> void:
	update_column_custom_counter(value)


func _on_mine_slider_value_changed(value: float) -> void:
	update_mine_custom_counter(value)


func _on_resign_pressed() -> void:
	_on_mine_revealed()
