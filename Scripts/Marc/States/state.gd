# voir ici pour la doc: https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/

#class_name State extends Node
#
##possiblité de rajouter data: Dictionary en arugment du signal. Sert à transmettre des valeurs.
#signal finished(next_state_name: String) ##ce signal est émis quand un état veut passer à un autre état. next_state_name est le nom de la node de l'état à laquelle on passe.
#
##possiblité de rajouter data: Dictionary en arugment du signal. Sert à transmettre des valeurs.
#func enter(_previous_state_name: String) -> void: ##appelé quand un état devient actif. previous_state_name est le nom de la node de l'état précédent.
	#pass
	#
#func exit() -> void: ##appelé juste avant de quitter l'état
	#pass
	#
#func physics_update(_delta: float) -> void: ## ppelé à chaque frame physique de l'état actif
	#pass


#region possibilité de rajouter les fonctions suivantes:

### Called by the state machine when receiving unhandled input events.
#func handle_input(_event: InputEvent) -> void:
	#pass

### Called by the state machine on the engine's main loop tick.
#func update(_delta: float) -> void:
	#pass
