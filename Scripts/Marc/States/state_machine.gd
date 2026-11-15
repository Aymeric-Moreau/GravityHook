class_name StateMachine extends Node

## État de départ. S'il est vide, on prend le premier enfant.
#@export var initial_state: State = null
#
#var state: State
#
#func _ready() -> void:
	#state = initial_state if initial_state != null else get_child(0)
#
	#for state_node: State in find_children("*", "State"):
		#state_node.finished.connect(transition_to)
#
	## On attend que le joueur soit prêt avant de lancer le premier état.
	#await owner.ready
	#state.enter("")
#
### Appelée par le joueur à chaque frame physique.
#func physics_update(delta: float) -> void:
	#state.physics_update(delta)
#
### Change d'état. Publique : le joueur l'utilise aussi pour le respawn.
#func transition_to(target_state_name: String) -> void:
	#if not has_node(target_state_name):
		#printerr(owner.name, " : l'état '", target_state_name, "' n'existe pas.")
		#return
#
	#var previous_name := state.name
	#state.exit()
	#state = get_node(target_state_name)
	#state.enter(previous_name)
