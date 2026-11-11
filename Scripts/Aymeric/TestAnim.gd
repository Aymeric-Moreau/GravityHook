extends Node2D

#var anchor :Vector2 = Vector2(200.0,200.0)
#var point : Vector2 = Vector2(200.0,400.0)
#var point2 : Vector2 = Vector2(200.0,300.0)
@onready var body: Line2D = $Pate
@export var radius :int = 20
@export var anchor :Marker2D
@export var pointRepos :Marker2D



func _ready() -> void:
	
	for i in range(0,body.points.size()):
		body.points[i] = Vector2(i*2,200.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var body_pts = body.points
	
	var move = Vector2( Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
	Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	
	#if move != Vector2.ZERO:
		#body_pts[0] += move * 200 * delta
	body_pts[0] = anchor.global_position
	body_pts[body_pts.size()-1] = pointRepos.global_position
	#point = anchor + (point - anchor).limit_length(12)
	#point2 = point + (point2 - point).limit_length(10)
	
	for i in range(1,body_pts.size() -1):
		body_pts[i] = body_pts[i - 1] + (body_pts[i] - body_pts[i -1]).limit_length(radius)
		body.points = body_pts
	queue_redraw()
	
#func _draw() -> void:
	#
	#draw_circle(anchor,10,"white")
	#draw_line(anchor,point,"red",5)
	#draw_circle(point,10,"green")
	#draw_circle(point2,8,"blue")
