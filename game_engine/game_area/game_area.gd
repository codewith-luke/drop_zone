extends Node

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
	var player_ball = player_ball.instantiate()
	var collision_entity = player_ball.get_node("RigidBody2D/CollisionShape2D")
	var ball_size = collision_entity.get_shape().get_rect().size
	position.y = position.y - ball_size.x;
	position.x = position.x - (ball_size.y / 2);
	player_ball.position = position
	print("size: ", player_ball.position)
	players += 1
	add_child(player_ball)
	HUD_NODE.update_player_count(players);
	
	
	
	
