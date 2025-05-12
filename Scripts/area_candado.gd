extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Papyrus":
		var cantidades = get_tree().get_root().get_node("Snowdin").cantidades
		$Candado.mostrar_candado(cantidades["antorcha"], cantidades["arbol"], cantidades["bola_nieve"])
		body.set_physics_process(false)  # Bloquea el movimiento de Papyrus

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Papyrus":
		$Candado.ocultar_candado()
		body.set_physics_process(true)  # Permite el movimiento de Papyrus
