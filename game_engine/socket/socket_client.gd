extends Node

signal on_socket_interaction

var websocket_url = "ws://localhost:8081/ws"

var socket = WebSocketPeer.new()

func _ready():
	socket.connect_to_url(websocket_url)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			var json_object = JSON.new()
			var parse_err = json_object.parse(packet.get_string_from_ascii())
			
			if parse_err:
				print("woops")
				continue
				
			var data = json_object.data
			on_socket_interaction.emit(data)
			
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
