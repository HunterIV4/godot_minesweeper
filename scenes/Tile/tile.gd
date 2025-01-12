class_name Tile
extends TextureButton

enum State {SAFE, CAUTION, MINE}
@export var textures: TileTextures

var mines_nearby: int = 0
var state: State = State.SAFE

var is_hidden := true
var is_flagged := false
var grid_position := Vector2.ZERO

var _disabled := false

## Modify State
## --------------------------

func reveal() -> bool:
	is_hidden = false
	_update_state()
	# Returns true if revealed to be a mine
	return state == State.MINE


func enable_input() -> void:
	_disabled = false


func disable_input() -> void:
	_disabled = true


func _update_state() -> void:
	if is_hidden:
		_set_flag_state()
	else:
		match state:
			State.SAFE:
				texture_normal = textures.safe
			State.MINE:
				if is_flagged:
					texture_normal = textures.mine_selected
				else:
					texture_normal = textures.mine
			State.CAUTION:
				_set_caution_state()


func _set_flag_state() -> void:
	if not is_hidden: return
	if is_flagged:
		texture_normal = textures.flagged
	else:
		texture_normal = textures.hidden


func _set_caution_state() -> void:
	assert(state == State.CAUTION, "_set_caution_state() called in invalid state")
	assert(mines_nearby > 0 and mines_nearby < 9, "_set_caution_state() called with an invalid number of nearby mines (1-8 are valid): " + str(mines_nearby))
	
	match mines_nearby:
		1: texture_normal = textures.c_1
		2: texture_normal = textures.c_2
		3: texture_normal = textures.c_3
		4: texture_normal = textures.c_4
		5: texture_normal = textures.c_5
		6: texture_normal = textures.c_6
		7: texture_normal = textures.c_7
		8: texture_normal = textures.c_8


## Setters
## --------------------------

func set_textures(tile_textures: TileTextures):
	textures = tile_textures
	_update_state()


func set_grid_position(pos: Vector2):
	grid_position = pos


func set_mines_nearby(mines: int):
	mines_nearby = mines
	if mines_nearby == 0:
		state = State.SAFE
	else:
		state = State.CAUTION
	_update_state()


## Input Handling
## --------------------------

func _gui_input(event: InputEvent) -> void:
	if not _disabled and event is InputEventMouseButton and event.pressed and is_hidden:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				var mine_found = reveal()
				_update_state()
				Events.tile_pressed.emit(self, MouseButton.MOUSE_BUTTON_LEFT)
				if mine_found:
					Events.mine_revealed.emit()
			
			MOUSE_BUTTON_RIGHT:
				is_flagged = !is_flagged
				_set_flag_state()
				Events.tile_pressed.emit(self, MouseButton.MOUSE_BUTTON_RIGHT)
				
