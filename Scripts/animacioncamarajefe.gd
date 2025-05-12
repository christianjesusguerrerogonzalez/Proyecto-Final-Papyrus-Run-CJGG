extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal jefe_cinematic_activa(tiempo)

var has_activated: bool = false  

func _ready() -> void:
	if not is_in_group("areas_jefe"):
		add_to_group("areas_jefe")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Papyrus" and not has_activated:
		InputMap.action_erase_events("cerrar")
		GameState.cinematic_active = true  # Bloquear entrada para otras funcionalidades
		animation_player.play("Camara_Jefe")
		has_activated = true  # Marcar como activado
		emit_signal("jefe_cinematic_activa", 7.0)
		# Esperar al final de la animación utilizando await
		await animation_player.animation_finished
		GameState.cinematic_active = false  # Reanudar entrada
		var cerrar_event = InputEventKey.new()
		cerrar_event.physical_keycode = Key.KEY_X  
		InputMap.action_add_event("cerrar", cerrar_event)
