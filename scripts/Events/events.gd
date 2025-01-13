## Autoload: Events
extends Node

#region Gameplay Signals
signal tile_pressed(tile: Tile, button: MouseButton)
signal tile_flagged()
signal reset_game()
signal mine_revealed()
signal game_ended(correctly_flagged: int, max_mines: int)
#endregion

#region UI Signals
signal game_over(message: String)
signal board_updated(rows: int, cols: int, mines: int)
signal time_updated(minutes: int, seconds: int)
#endregion
