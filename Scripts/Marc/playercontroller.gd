extends CharacterBody2D

#states
enum State { NORMAL, SWINGING }
var state: State = State.NORMAL

var is_flipped : bool = false

#données du grappin en cours
var grapple_point: Vector2
var grapple_distance: float
var grapple_angle: float #angle actuel du grapple autour du point de rotation en radian
var swing_dir: float #sens de rotation du grappin
var swing_travelled : float #angle déjà parcouru par le grappin, en radian
var facing : float #dans quel direction le joueur va shoot son grappin et swing

#var is_grappled = false #je crois que is_grappled et did_grappled hit peuvent être fusionné en une seule et même variable
#var did_grappled_hit = false

@export_category("connexions")
@export var hitbox_grapple : RayCast2D
@export var pivot_flip: Node2D #on est obligé d'utiliser un pivot pour flip le characterbody2D, car quand horizontalement le spirte est considéré comme étant rotate à 180° (me demandez pas pk)
@export var sprite_grapple: Sprite2D
#@export var timer_grapple_launch : Timer
#@export var timer_grapple_activate : Timer

@export_category("mouvement")
@export var JUMP_VELOCITY : float = -400.0
@export var SPEED : float = 300

@export_category("shoot grappin")
@export var grapple_launch_angle : float = 45.0 # en degrees
@export var grapple_range : float = 400.0

@export_category("swing grappin")
@export var swing_total_distance : float = 90 #distance de swing en degrée
@export var swing_speed : float = 115 #vitesse de swing en degrees par secondes






func _ready() -> void:
	hitbox_grapple.enabled = true #je me souviens honnetement plus à quoi sert cette ligne de code
	hitbox_grapple.target_position = Vector2.from_angle(-deg_to_rad(grapple_launch_angle)) * grapple_range #set la position de la fèche du raycast2D de détéction du grapple. Vector2.from_angle() créer un vecteur de taille 1 à l'angle voulue.
	
	#on initialise les paramètre du sprite du grappin
	sprite_grapple.rotation = -deg_to_rad(grapple_launch_angle)
	sprite_grapple.position = hitbox_grapple.target_position/2
	sprite_grapple.hide()

func _physics_process(delta: float) -> void:
	
	match state: #match ça permet de faire if state == state.normal, else if state == state.swinging etc.
		State.NORMAL:
			_physics_normal(delta)
		State.SWINGING:
			_physics_swinging(delta)
	
	move_and_slide()


##-----ETAT NORMAL-------
func _physics_normal(delta: float) -> void:
	
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
		
		
	#permet de flip le perso vers la gauche
	if (Input.is_action_just_pressed("ui_left") and is_flipped == false):
		pivot_flip.transform.x = Vector2.LEFT
		is_flipped = true
	#permet de flip le perso vers la droite
	if (Input.is_action_just_pressed("ui_right") and is_flipped == true) :
		pivot_flip.transform.x = Vector2.RIGHT
		is_flipped = false

	
	#enclenche le grappin
	if Input.is_action_just_pressed("Grappin"):
		_shoot_grapple()
		




##-----SHOOT DU GRAPPIN-----
func _shoot_grapple() -> void:
	
	hitbox_grapple.force_raycast_update() #actualise le raycast au moment du tir
	
	if not hitbox_grapple.is_colliding(): 	#on test si le grappin touche quelque chose. 
		return  #Si le grappin ne touche rien, alors la fonction s'arrête ici.
		
	grapple_point = hitbox_grapple.get_collision_point() #la coordonnée que le grappin à hit
	
	var offset_player_grapplepoint = global_position - grapple_point #différence de position entre le joueur et le point d'accroche
	grapple_distance = offset_player_grapplepoint.length() #distance entre le joueur et le point d'accroche
	grapple_angle = offset_player_grapplepoint.angle() #angle du vecteur entre le joueur et le point d'accroche
	swing_travelled = 0.0 #rénitialise la distance parcourue par le grappin
	
	#facing permet de dire dans quel direction le grappin va effectuer ses calculs.
	if is_flipped == true: 
		facing = -1.0
	else: 
		facing = 1.0
	swing_dir = -facing

	state = State.SWINGING #le state du joueur devient le state swinging du grappin.
	sprite_grapple.show()




## -------- ETAT DE SWING DU GRAPPIN --------
func _physics_swinging(delta: float) -> void:
	
	var swing_distance_rad : float = deg_to_rad(swing_total_distance) #convertis en radian la distance parcouru avec le grappin
	var step : float = deg_to_rad(swing_speed) * delta #angle en radian à parcourir durant cette frale
	step = min(step, swing_distance_rad - swing_travelled) #sert à ne pas dépasser 90° à la dernière frame. Jsp à quel point c'est une façon propre de faire.

	swing_travelled += step #on actualise la distance parcourue
	grapple_angle += swing_dir * step #on actualise l'angle actuel
	
	if grapple_point.x * facing <= global_position.x * facing: #si l'arraignée atteint la position verticale du point d'accroche
		rotation += swing_dir * step #on fait tourner toute l'arraignée
	else:
		hitbox_grapple.rotation += swing_dir * step * facing #on seulement fait tourner le sprite du grappin


	var player_position_target : Vector2 = grapple_point + Vector2.from_angle(grapple_angle) * grapple_distance # Position voulue du joueur sur le cercle
	velocity = (player_position_target - global_position) / delta # on calcul la vélocité qu'on doit appliqué au joueur pour qu'il atteigne la position voulue. On utilise la vélocité pour pas que le joueur se tp à travers les murs

	if swing_travelled >= swing_distance_rad: # si on atteint la distance/l'angle max, on lâche le grappin
		state = State.NORMAL 
		
		#les sprite du joueur et du grapple
		hitbox_grapple.rotation = 0 
		rotation = 0
		sprite_grapple.hide()











#region ancien code, à jeter?

	#if is_grappled == false:
		#_physics_hors_grapple(delta) #tout ce qu'il se passe quand le joueur n'est pas en état de grappin
		
		
	
	
	#tout ce qui se passe au moment ou le grappin est enclenché
	#if hitbox_grapple.is_colliding() and did_grappled_hit == false: 
		#
		#is_grappled = true #devient en état de grappin
		#did_grappled_hit = true #le grappin a touché qq chose
		#
		#var grapple_point = hitbox_grapple.get_collision_point() #coordonnées de collision du grappin
		#timer_grapple_activate.start()
		#
		#velocity = Vector2(grapple_speed, grapple_speed)
		#
		#
	##tout ce qui se passe tant que le joueur est en état de grappin
	#if is_grappled == true:
		#
		#rotation -= grapple_angular_velocity * delta * 50 #rotationne le joueur
		#velocity = velocity.rotated(-grapple_angular_velocity)
		#
		#
		#
	##tout ce qui se passe au moment le grappin est desactivé
	#if timer_grapple_launch.is_stopped() and timer_grapple_activate.is_stopped():
		#
		#hitbox_grapple.enabled = false
		#hitbox_grapple.hide()
		#
		#is_grappled = false
		#did_grappled_hit = false
		#
		#rotation_degrees = 0
#endregion
