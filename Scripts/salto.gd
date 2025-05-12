extends Area2D

@export var jump_duration: float = 0.8  # Duración del salto
@export var de_derecha_a_izquierda: bool = false  # Define si el salto será de derecha a izquierda
static var is_jumping: bool = false  # Bandera global para verificar si se está realizando un salto

func _on_body_entered(body):
	# Verifica que el jugador sea "Papyrus" y que no esté saltando
	if body.name == "Papyrus" and not is_jumping:
		is_jumping = true  # Marca que el jugador está en medio de un salto

		# Desactiva el control del jugador
		body.set_physics_process(false)

		# Determina posiciones de inicio y fin del salto
		var start_position = body.position
		var end_position = calculate_end_position(start_position)

		# Ejecuta el salto dinámico y espera a que termine
		await perform_jump(body, start_position, end_position)
		
		# Reactiva el control del jugador y desbloquea el salto
		body.set_physics_process(true)
		is_jumping = false  # Marca que el salto ha terminado

func calculate_end_position(start_position: Vector2) -> Vector2:
	# Determinar dirección del salto según `de_derecha_a_izquierda`
	var area_size = get_node("CollisionShape2D").shape.extents.x * 2
	if de_derecha_a_izquierda:
		return Vector2(position.x - area_size, position.y)
	else:
		return Vector2(position.x + area_size, position.y)

func perform_jump(body, start_position: Vector2, end_position: Vector2) -> void:
	var elapsed_time = 0.0
	while elapsed_time < jump_duration:
		await get_tree().process_frame
		elapsed_time += get_process_delta_time()
		var t = elapsed_time / jump_duration

		# Movimiento interpolado entre inicio y fin utilizando `lerp`
		body.position = start_position.lerp(end_position, t)
