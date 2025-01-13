### MINESWEEPER Godot 4.3 example - original by Awf Ibrahim (@awfyboy)
### Updated and refactored by HunterIV4
class_name Game
extends Node

@onready var timer: Timer = %GameTimer

var minutes: int = 0
var seconds: int = 0

func _ready() -> void:
	Events.reset_game.connect(_on_reset_game)
	Events.game_ended.connect(_on_game_ended)
	

## Game Events
## --------------------------

func _on_game_ended(correctly_flagged: int, max_mines: int):
	var message := ""
	# Game won if equal
	if correctly_flagged == max_mines:
		message = "You won! All %d mines were correctly identified. Play again?" % correctly_flagged
	else:
		message = "Game Over! You found %d mines out of %d. Play again?" % [correctly_flagged, max_mines]
	timer.stop()
	Events.game_over.emit(message)


func _on_reset_game() -> void:
	minutes = 0
	seconds = 0
	Events.time_updated.emit(minutes, seconds)
	timer.start()


func _on_game_timer_timeout() -> void:
	seconds += 1
	if seconds > 60:
		minutes += 1
		seconds = 0
	Events.time_updated.emit(minutes, seconds)
