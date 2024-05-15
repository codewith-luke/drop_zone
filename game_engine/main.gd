extends Node

var players = 0
var player_lobby = {} 
var player_add_control
var game_width
var game_height
var button_width
var button_height

func _ready():
	on_game_area_ready()
	$GameArea.on_add_player.connect(on_player_add)
	$SocketClient.on_socket_interaction.connect(on_socket_interaction)	

func _process(delta):
	pass
	
func on_game_area_ready():
	set_game_dimensions()
	set_button_dimensions()

func set_game_dimensions():
	if (game_height == null || game_width == null):
		var game_dimensions = get_viewport().get_visible_rect().size
	
		game_width = game_dimensions[0];
		game_height = game_dimensions[1];

func set_button_dimensions():
	if (button_width == null || button_height == null || button_width == 0 || button_height == 0):
		player_add_control = $GameArea/PanelContainer/Control;	
		var player_add_control_dimensions = player_add_control.get_size()
		
		button_width = player_add_control_dimensions[0]
		button_height = player_add_control_dimensions[1]

func on_player_add():
	players += 1
	$HUD.update_player_count(players);

func on_socket_interaction(data):
	#if player_lobby.has(data.id):
		#return

	player_lobby[data.id] = data.id;	
	
	print("game_area", game_width, game_height)
	validate_click_location(data)
	player_add_control.get_node("AddPlayerButton").emit_signal("pressed")

func validate_click_location(data):
	set_button_dimensions()
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

