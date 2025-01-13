class_name PlayArea
extends Control

@export var difficulty_easy: Difficulty
@export var difficulty_normal: Difficulty
@export var difficulty_hard: Difficulty
var DIFFICULTY_DEFAULT: Difficulty = load("res://scenes/Gui/default_difficulty.tres")

@onready var mine_counter: Label = %MineCounter
@onready var time_elapsed: Label = %TimeElapsed
@onready var message: Label = %Message
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

func _ready() -> void:
	Events.tile_flagged.connect(_on_tile_flagged)
	Events.game_over.connect(_on_game_over)
	Events.time_updated.connect(_on_time_updated)
	
	# Set initial board state and hide gameplay UI
	Events.board_updated.emit(row_slider.value, column_slider.value, mine_slider.value)
	main_game.hide()
	
	# Ensure a valid default is set for each option
	if not difficulty_easy:
		difficulty_easy = DIFFICULTY_DEFAULT
	if not difficulty_normal:
		difficulty_normal = DIFFICULTY_DEFAULT
	if not difficulty_hard:
		difficulty_hard = DIFFICULTY_DEFAULT
	
	_set_difficulty(DIFFICULTY_DEFAULT)
	update_mine_guess_counter()

## Game Events
## --------------------------

func _on_game_over(msg: String) -> void:
	menu_options.show()
	board.disable_tiles()
	message.text = msg
	message.show()
	resign.hide()


func _on_message_updated(new_message: String) -> void:
	message.text = new_message


func _on_reset_game() -> void:
	board.reset()
	update_mine_guess_counter()
	message.hide()


func _on_tile_flagged() -> void:
	update_mine_guess_counter()


## UI Controls
## --------------------------

func _on_start_game_pressed() -> void:
	Events.board_updated.emit(row_slider.value, column_slider.value, mine_slider.value)
	Events.reset_game.emit()
	main_game.show()
	resign.show()
	menu_options.hide()
	message.hide()
	update_mine_guess_counter()


func _on_resign_pressed() -> void:
	Events.mine_revealed.emit()


func _set_difficulty(new_difficulty: Difficulty) -> void:
	row_slider.value = new_difficulty.rows
	column_slider.value = new_difficulty.columns
	mine_slider.value = new_difficulty.mines


func _on_easy_pressed() -> void:
	_set_difficulty(difficulty_easy)


func _on_normal_pressed() -> void:
	_set_difficulty(difficulty_normal)


func _on_hard_pressed() -> void:
	_set_difficulty(difficulty_hard)


func _on_row_slider_value_changed(value: float) -> void:
	row_counter.text = "Rows: %s" % value


func _on_column_slider_value_changed(value: float) -> void:
	column_counter.text = "Columns: %s" % value


func _on_mine_slider_value_changed(value: float) -> void:
	max_mine_counter.text = "Mines: %s" % value

## Visual Updates
## --------------------------

func update_mine_guess_counter() -> void:
	var mine_count = max(board.max_mines - board.get_flagged_mine_count(), 0)
	mine_counter.text = "Mines: %s" % (mine_count)


func _on_time_updated(minutes: int, seconds: int) -> void:
	time_elapsed.text = "Time: %02d:%02d" % [minutes, seconds]
