extends Area2D

var rotation_angle : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	rotation_angle = rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered( body: Node2D ) -> void:
	if body.is_in_group("Player"):
		body.current_level.rotation = -rotation
		body.rotation = rotation
		
		if body.state != body.State.NORMAL :
			body._exit_swing()
			
		print("gravity change")
