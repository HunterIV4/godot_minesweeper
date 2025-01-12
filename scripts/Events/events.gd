# Autoload: Events
extends Node

# Gameplay board signals
signal update_tile_state(tile: Tile, new_state: Tile.State)
signal tile_pressed(tile: Tile, button: MouseButton)
signal mine_revealed(tile: Tile)

signal board_updated(rows: int, cols: int, mines: int)
