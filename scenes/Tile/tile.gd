extends TextureButton
class_name Tile

enum State {SAFE, CAUTION, MINE}

@export var img_hidden: Texture2D
@export var img_safe: Texture2D
@export var img_mine: Texture2D
@export var img_mine_selected: Texture2D
@export var img_flagged: Texture2D
@export var img_1: Texture2D
@export var img_2: Texture2D
@export var img_3: Texture2D
@export var img_4: Texture2D
@export var img_5: Texture2D
@export var img_6: Texture2D
@export var img_7: Texture2D
@export var img_8: Texture2D

var mines_nearby: int = 0
var state: State = State.SAFE

var is_hidden: bool = true
var is_flagged: bool = false

func _ready() -> void:
	Events.update_tile_state.connect(_on_update_tile_state)


func reveal() -> void:
	is_hidden = false


func _on_update_tile_state(tile: Tile, new_state: State) -> void:
	if tile != self: return
	state = new_state
	
	if is_hidden: return	# Don't update visuals if still hidden
	_update_state()
	
func _update_state() -> void:
	match state:
		State.SAFE:
			texture_normal = img_safe
		State.MINE:
			if is_flagged:
				texture_normal = img_mine_selected
			else:
				texture_normal = img_mine
		State.CAUTION:
			_set_caution_state()


func _set_flag_state() -> void:
	if not is_hidden: return
	if is_flagged:
		texture_normal = img_flagged
	else:
		texture_normal = img_hidden


func _set_caution_state() -> void:
	assert(state == State.CAUTION, "_set_caution_state() called in invalid state")
	assert(mines_nearby > 0 and mines_nearby < 9, "_set_caution_state() called with an invalid number of nearby mines (1-8 are valid): " + str(mines_nearby))
	
	match mines_nearby:
		1: texture_normal = img_1
		2: texture_normal = img_2
		3: texture_normal = img_3
		4: texture_normal = img_4
		5: texture_normal = img_5
		6: texture_normal = img_6
		7: texture_normal = img_7
		8: texture_normal = img_8

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and is_hidden:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				Events.tile_pressed.emit(self, MouseButton.MOUSE_BUTTON_LEFT)
				
				is_hidden = false
				_update_state()
				
			MOUSE_BUTTON_RIGHT:
				Events.tile_pressed.emit(self, MouseButton.MOUSE_BUTTON_RIGHT)
				
				is_flagged = !is_flagged
				_set_flag_state()
