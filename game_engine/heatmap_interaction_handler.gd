extends Node

@onready var GAME_AREA_NODE = $"../GameArea"
@onready var HUD_NODE = $"../HUD"
@onready var SOCKET_CLIENT_NODE = $"../SocketClient"

var players = 0
var player_lobby = {} 
var player_add_control
var game_width
var game_height
var button_width
var button_height

func _ready():
	print("loaded heatmap interaction handler")
	_create()
	pass
	
func _process(_delta):
	pass

func _create():
	_set_game_dimensions()
	_set_button_dimensions()
	GAME_AREA_NODE.on_add_player.connect(_on_player_add)
	SOCKET_CLIENT_NODE.on_socket_interaction.connect(_on_socket_interaction)	
	
func _set_game_dimensions():
	if (game_height == null || game_width == null):
		var game_dimensions = get_viewport().get_visible_rect().size
	
		game_width = game_dimensions[0];
		game_height = game_dimensions[1];

func _set_button_dimensions():
	if (button_width == null || button_height == null || button_width == 0 || button_height == 0):
		player_add_control = GAME_AREA_NODE.get_node("PanelContainer/Control")
		var player_add_control_dimensions = player_add_control.get_size()
		
		button_width = player_add_control_dimensions[0]
		button_height = player_add_control_dimensions[1]

func _on_player_add():
	players += 1
	HUD_NODE.update_player_count(players);

func _on_socket_interaction(data):
	player_lobby[data.id] = data.id;	
	_validate_click_location(data)
	player_add_control.get_node("AddPlayerButton").emit_signal("pressed")

func _validate_click_location(data):
	_set_button_dimensions()
	var player_x = game_width * float(data.x);
	var player_y = game_height * float(data.y);
	var results = {
		"x": player_x,
		"y": player_y
	}

	print(button_width, button_height)
	print(player_x <= button_width)
	print(player_y <= button_height)
	print(player_x >= 0)
	print(player_y >= 0)
	
	return results

