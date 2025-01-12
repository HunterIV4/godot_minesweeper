## Autoload: Events
extends Node

## Gameplay Signals
## --------------------------
signal tile_pressed(tile: Tile, button: MouseButton)
signal tile_flagged()
signal mine_revealed()
signal board_updated(rows: int, cols: int, mines: int)
