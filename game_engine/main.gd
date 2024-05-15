extends Node

var players = 0

func _ready():
	$GameArea.on_add_player.connect(on_player_add)
	get_node("SocketClient").on_socket_interaction.connect(on_socket_interaction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_player_add():
	players += 1
	$HUD.update_player_count(players);
	
func on_socket_interaction(data):
	print("player_data", data)
	$GameArea/PanelContainer/AddPlayerButton.emit_signal("pressed")


