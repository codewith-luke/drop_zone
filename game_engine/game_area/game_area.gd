extends Node

signal on_add_player

# Called when the node enters the scene tree for the first time.
func _ready():
	print("loaded main")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_add_player_pressed():
	on_add_player.emit()
	
	
	
	
