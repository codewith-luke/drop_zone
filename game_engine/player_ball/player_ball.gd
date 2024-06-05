extends RigidBody2D

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)

func _process(delta):
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	print("deleted node")
	queue_free()
