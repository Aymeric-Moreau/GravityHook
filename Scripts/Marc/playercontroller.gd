extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_flipped = false
var is_grappled = false
var did_grappled_hit = false

@export var hitbox_grapple : RayCast2D
@export var timer_grapple_launch : Timer
@export var timer_grapple_activate : Timer

@export var grapple_speed : float = 200
@export var grapple_angular_velocity : float = 1

func _ready() -> void:
	hitbox_grapple.enabled = true

func _physics_process(delta: float) -> void:
	
	if is_grappled == false:
		_physics_hors_grapple(delta)
		
	
	if hitbox_grapple.is_colliding() and did_grappled_hit == false: #collision grappin
		
		#tout ça se passe au moment ou il grappine
		
		is_grappled = true
		did_grappled_hit = true
		
		var grapple_point = hitbox_grapple.get_collision_point()
		timer_grapple_activate.start()
		
		velocity = Vector2(grapple_speed, grapple_speed)
		
	if is_grappled == true:
		
		#tout ça se passe tant qu'il est grappin
		rotation -= grapple_angular_velocity * delta
		
		
		print("état grapple")
		
		
		
	#tout ça se passe quand le grappin est desactivé
	if timer_grapple_launch.is_stopped() and timer_grapple_activate.is_stopped():
		hitbox_grapple.enabled = false
		hitbox_grapple.hide()
		
		is_grappled = false
		did_grappled_hit = false
		

		

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
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	#flip character body
	if (Input.is_action_just_pressed("ui_left") and is_flipped == false):
		scale.x = -1
		is_flipped = true
		
	if (Input.is_action_just_pressed("ui_right") and is_flipped == true) :
		scale.x = -1
		is_flipped = false
	
	
	#enclenche grappin
	if Input.is_action_just_pressed("Grappin"):
		
		hitbox_grapple.enabled = true
		hitbox_grapple.show()
		timer_grapple_launch.start()
		
		
	

	
