extends CharacterBody2D


const SPEED = 300.0


var is_flipped = false
var is_grappled = false #je crois que is_grappled et did_grappled hit peuvent être fusionné en une seule et même variable
var did_grappled_hit = false

@export var hitbox_grapple : RayCast2D
@export var pivot: Node2D
@export var timer_grapple_launch : Timer
@export var timer_grapple_activate : Timer

@export var JUMP_VELOCITY = -400.0

@export var grapple_speed : float = 200
@export var grapple_angular_velocity : float = 1


func _ready() -> void:
	hitbox_grapple.enabled = true

func _physics_process(delta: float) -> void:
	
	if is_grappled == false:
		_physics_hors_grapple(delta) #tout ce qu'il se passe quand le joueur n'est pas en état de grappin
		
		
	#tout ce qui se passe au moment ou le grappin est enclenché
	if hitbox_grapple.is_colliding() and did_grappled_hit == false: 
		
		is_grappled = true #devient en état de grappin
		did_grappled_hit = true #le grappin a touché qq chose
		
		var grapple_point = hitbox_grapple.get_collision_point() #coordonnées de collision du grappin
		timer_grapple_activate.start()
		
		velocity = Vector2(grapple_speed, grapple_speed)
		
		
	#tout ce qui se passe tant que le joueur est en état de grappin
	if is_grappled == true:
		
		rotation -= grapple_angular_velocity * delta * 50 #rotationne le joueur
		velocity = velocity.rotated(-grapple_angular_velocity)
		
		
		
	#tout ça se passe au moment le grappin est desactivé
	if timer_grapple_launch.is_stopped() and timer_grapple_activate.is_stopped():
		
		hitbox_grapple.enabled = false
		hitbox_grapple.hide()
		
		is_grappled = false
		did_grappled_hit = false
		
		rotation_degrees = 0


		

	move_and_slide()

#tout ce bloc est appelé lorsque le perso n'est pas en grapple
func _physics_hors_grapple(delta:float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	#flip character body
	if (Input.is_action_just_pressed("ui_left") and is_flipped == false):
		pivot.transform.x = Vector2.LEFT
		is_flipped = true
		
	if (Input.is_action_just_pressed("ui_right") and is_flipped == true) :
		pivot.transform.x = Vector2.RIGHT
		is_flipped = false
	
	
	#enclenche le grappin
	if Input.is_action_just_pressed("Grappin"):
		
		hitbox_grapple.enabled = true
		hitbox_grapple.show()
		timer_grapple_launch.start()
		
		
	

	
