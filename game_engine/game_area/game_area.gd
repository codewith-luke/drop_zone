extends Node

signal on_add_player

@export var player_ball: PackedScene

@onready var HEATMAP_NODE = $"../HeatmapInteractionHandler"
@onready var HUD_NODE = $"../HUD"

var players = 0
var player_lobby = {} 

# Called when the node enters the scene tree for the first time.
func _ready():
	HEATMAP_NODE.on_player_heatmap_click.connect(_on_player_add)
	print("loaded game area")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_add_player_pressed():	
	var mouse_position = get_viewport().get_mouse_position()
	_on_player_add(mouse_position)
	
func _on_player_add(position):
	print("button clicked")
	var playerBall = player_ball.instantiate()
	playerBall.position = position
	print(position)
	add_child(playerBall)
	on_add_player.emit()
	players += 1
	HUD_NODE.update_player_count(players);
	
	
	
	
