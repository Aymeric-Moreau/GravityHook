extends CharacterBody2D

#states
enum State { NORMAL, SWINGING }
var state: State = State.NORMAL

var is_flipped : bool = false

#données actuelles du grappin
var grapple_current_range: float ##portée actuel du grappin
var grapple_current_launch_angle: float ##angle de tir actuel du grappin en radian
var current_swing_speed: float ##vitesse actuel du grappin

#données générales du grappin
var grapple_point: Vector2 ##point d'accroche du grappin
var grapple_distance: float ##distance entre le point d'accroche du grappin et le joueur
var grapple_angle: float ##angle actuel du grapple autour du point de rotation en radian
var swing_dir: float ##sens de rotation du grappin
var swing_travelled : float ##angle déjà parcouru par le grappin, en radian
var facing : float ##dans quel direction le joueur va shoot son grappin et swing

#données de realease du grappin
var release_target_angle : float ##angle en radian auquel le joueur sera lâché
var must_grapple_release : bool ##true une fois que le joueur a relâché le bouton de grappin pendant un swing.

@export_category("connexions")
@export var hitbox_grapple : RayCast2D ##raycast de détéction du grappin
@export var pivot_flip: Node2D ## on est obligé d'utiliser un pivot pour flip le characterbody2D, car quand horizontalement le spirte est considéré comme étant rotate à 180° (me demandez pas pk)
@export var rope_line : Line2D ##représentation visuel du grappin, line2D.
@export var sprite_spider: Sprite2D ##sprite de l'arraignée

@export_category("mouvement")
@export var JUMP_VELOCITY : float = -400.0
@export var SPEED : float = 300

@export_category("grappin")
@export_group("shoot grappin")
@export var grapple_base_launch_angle : float = 45.0 ## angle de lancement du grappin de base en degrees
@export var grapple_base_range : float = 400.0 ## portée du grappin de base
@export var velocity_range_multiplier : float = 1 ##lorsque le joueur utilise le grappin après une chute, cela augmente la portée du grappin. Cette variable est le multiplicateur qui détermine à quel point la portée augmente.

@export_group("swing grappin")
#@export var swing_total_distance : float = 90 ##distance à partir de laquelle le grapprin est relaché, en degrée
@export var base_swing_speed : float = 115 ##vitesse de swing en degrees par secondes
@export var swing_speed_multiplier : float = 1 ##lorsque le joueur utilise le grappin après une chute, cela augmente sa vitesse de swing. Cette variable est le mutliplicateur de la vitesse de swing lorsque le joueur chute.
@export var rope_width : float = 3.0 ## épaisseur de la "corde" lorsque le joueur est en état de swing. Purement visuel.

@export_group("release grappin")
@export var first_release_angle : float = 0
@export var second_release_angle : float = 45
@export var third_release_angle : float = 90



func _ready() -> void:
	#hitbox_grapple.enabled = true #je me souviens honnetement plus à quoi sert cette ligne de code, je crois qu'elle est inutile
	_update_grapple_raycast() #initialise le raycast du grappin
	
	#initialisation du la ligne qui va servir à représenter le grappin visuellement
	rope_line.top_level = true #pose la corde tout en haut de la hiérarchie, pour qu'elle ignore la rotationdu joueur
	rope_line.width = rope_width #détermine la largeur de la corde
	rope_line.points = [Vector2.ZERO, Vector2.ZERO] #nombre de points que la ligne va utiliser
	rope_line.hide()




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


	_update_grapple_raycast() #actualise le raycast du grappin
	
	#enclenche le grappin
	if Input.is_action_just_pressed("Grappin"):
		_shoot_grapple()
		




func _update_grapple_raycast() -> void:
	
	if velocity.y > 0: #si le joueur est en train de chuter
		var horizontal_grapple_range : float = cos( deg_to_rad(grapple_base_launch_angle) ) * grapple_base_range # on calcule la portée horizontal du grappin. On veut qu'elle soit constante.
		
		grapple_current_range = grapple_base_range + (velocity.y / velocity_range_multiplier) #augmente la portée du grappin en fonction de la vitesse de chute
		grapple_current_launch_angle = -acos( horizontal_grapple_range / grapple_current_range ) #ajuste l'angle du grappin, pour que la portée horizontal du grappin soit constante.
		
	else:
		grapple_current_range = grapple_base_range
		grapple_current_launch_angle = -deg_to_rad(grapple_base_launch_angle)
	
	hitbox_grapple.target_position = Vector2.from_angle(grapple_current_launch_angle) * grapple_current_range #set la position de la fèche du raycast2D de détéction du grapple. Vector2.from_angle() créer un vecteur de taille 1 à l'angle voulue.
	




##-----SHOOT DU GRAPPIN-----
func _shoot_grapple() -> void:
	
	hitbox_grapple.force_raycast_update() #actualise le raycast au moment du tir
	
	if not hitbox_grapple.is_colliding(): 	#on test si le grappin touche quelque chose. 
		return  #Si le grappin ne touche rien, alors la fonction s'arrête ici.
		
	grapple_point = hitbox_grapple.get_collision_point() #la coordonnée que le grappin à hit
	
	var offset_player_grapplepoint = global_position - grapple_point #différence de position entre le joueur et le point d'accroche
	grapple_distance = offset_player_grapplepoint.length() #distance entre le joueur et le point d'accroche
	grapple_angle = offset_player_grapplepoint.angle() #angle du vecteur entre le joueur et le point d'accroche
	#swing_travelled = 0.0 #rénitialise la distance parcourue par le grappin. Ligne inutile avec la nouvelle méthode.
	must_grapple_release = false #reset si le grappin doit être release
	release_target_angle = deg_to_rad(third_release_angle) #angle par défaut de release du grappin, qui est le dernier angle

	
	#facing permet de dire dans quel direction le grappin va effectuer ses calculs.
	if is_flipped == true: 
		facing = -1.0
	else: 
		facing = 1.0
	swing_dir = -facing
	
	
	if velocity.y > 0: #si le joueur est en train de chuter
		current_swing_speed = base_swing_speed + ( velocity.y / swing_speed_multiplier ) #augmente la vitesse de swing du grappin du joueur en fonction de la vitesse de chute
	else:
		current_swing_speed = base_swing_speed
		
		
	state = State.SWINGING #le state du joueur devient le state swinging du grappin.
	
	_update_rope() # on actualise la position des points d'accroche du grappin visuel
	rope_line.show() #on affiche le grappin visuellement






## -------- ETAT DE SWING DU GRAPPIN --------
func _physics_swinging(delta: float) -> void:
	
	if not must_grapple_release and not Input.is_action_pressed("Grappin"): #si le joueur lache le bouton pendant qu'il swing
		must_grapple_release = true #le joueur a relaché le bouton
		
		if _get_swing_angle() < deg_to_rad(first_release_angle): #si l'angle est actuel est en dessous du premier angle possible de relache
			release_target_angle = deg_to_rad(first_release_angle) #on change la target release pour être le premier angle de relache
			
		else: if _get_swing_angle() < deg_to_rad(second_release_angle): #sinon, l'angle actuel est en dessous du second angle possible de relache
			release_target_angle = deg_to_rad(second_release_angle) #on change la target realease pour être le second angle de relache
	
	var step : float = deg_to_rad(current_swing_speed) * delta ##angle en radian à parcourir durant cette frame
	#step = clamp(release_target_angle - current_angle, 0.0, step) # potentiellement à rajouter pour que ce soit + propre  ATTENTION CETTE LIGNE DE CODE PEUT CREER DES BUGS
	
	#var swing_distance_rad : float = deg_to_rad(swing_total_distance) #convertis en radian la distance parcouru avec le grappin
	#step = min(step, swing_distance_rad - swing_travelled) #sert à ne pas dépasser la distance max voulue à la dernière frame. Jsp à quel point c'est une façon propre de faire. ATTENTION CETTE LIGNE DE CODE CREER DES BUGS

	#swing_travelled += step #on actualise la distance parcourue
	grapple_angle += swing_dir * step #on actualise l'angle actuel
	
	#animation de l'araignée pendant qu'elle swing
	#if grapple_point.x * facing <= global_position.x * facing: #si l'arraignée atteint la position verticale du point d'accroche
	if _get_swing_angle() >= 0: #si l'arraignée atteint la position verticale du point d'accroche
		sprite_spider.rotation += swing_dir * step * facing #on fait tourner le sprite de l'araignée
		
	_update_rope() #actualise la représentation visuelle de la corde du grappin
	

	#déplacer le joueur pendant le swing
	var player_position_target : Vector2 = grapple_point + Vector2.from_angle(grapple_angle) * grapple_distance # Position voulue du joueur sur le cercle
	velocity = (player_position_target - global_position) / delta # on calcul la vélocité qu'on doit appliqué au joueur pour qu'il atteigne la position voulue. On utilise la vélocité pour pas que le joueur se tp à travers les murs

	#if swing_travelled >= swing_distance_rad or get_slide_collision_count() > 0: # si on atteint la distance max, ou que le personnage touche une surface, on lâche le grappin
	#if grapple_angle >= deg_to_rad(first_release_angle) or get_slide_collision_count() > 0: # si on atteint la distance max, ou que le personnage touche une surface, on lâche le grappin
		#state = State.NORMAL #sort du grappin
		#sprite_spider.rotation = 0 #renitialise la rotation du sprite de l'arraignée
		#rope_line.hide() #cache la corde
	
	
	if _get_swing_angle() >= release_target_angle - 0.0001 or get_slide_collision_count() > 0: # si on atteint la distance max, ou que le personnage touche une surface, on lâche le grappin
		state = State.NORMAL #sort du grappin
		sprite_spider.rotation = 0 #renitialise la rotation du sprite de l'arraignée
		rope_line.hide() #cache la corde
		#velocity = _get_swing_exit_velocity() #potentiellement à rajouter pour que ce soit + propre






func _update_rope() -> void: ##update les points qui segmentent la line2D qui représente visuellement la corde. Permet l'animation de la corde.
	rope_line.set_point_position(0, grapple_point) #point de la corde attaché aux blocs, 0 c'est parce que c'est le premier point dans la liste.
	rope_line.set_point_position(1, global_position) #point de la corde attaché au joueur, 1 c'est parce que c'est le 2e point dans la liste.


func _get_swing_angle() -> float: ##permet de connaitre l'angle absolue de swing, peu importe la direction. 0° correspond à l'angle qui point strictement vers le bas.
	return -swing_dir * angle_difference(grapple_angle, PI / 2.0)



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
