extends Area2D

var velocidad: float = 200.0
var custom_direction: Vector2 = Vector2.ZERO
var follow_player: bool = false
var tiempo_vida: float = 5.0  # Tiempo de vida del proyectil en segundos
var gravedad: float = 100.0  # Velocidad de la caída del proyectil

func iniciar_ataque(vel: float, seguir: bool = false, direccion_inicial: Vector2 = Vector2.ZERO):
	velocidad = vel
	follow_player = seguir
	custom_direction = direccion_inicial  # Define la dirección inicial del proyectil
	tiempo_vida = 5.0

	if not follow_player:
		# Si no se sigue al jugador, el proyectil caerá hacia abajo
		custom_direction = Vector2(0, 1)  # Dirección hacia abajo

func _process(delta: float):
	tiempo_vida -= delta
	if tiempo_vida <= 0.0:
		queue_free()  # Destruye el proyectil al finalizar su tiempo de vida
	
	if follow_player:
		# Sigue al jugador constantemente
		var alma = get_parent().get_node("Alma")
		if alma:
			var direccion = (alma.position - position).normalized()
			position += direccion * velocidad * delta
	else:
		# Movimiento en la dirección inicial calculada (caída hacia abajo)
		position += custom_direction * velocidad * delta
		# Simulamos gravedad para que el proyectil caiga más rápido con el tiempo
		velocidad += gravedad * delta  # Aumenta la velocidad de caída con el tiempo

# Nueva función: Manejo de colisión con el alma
func _on_proyectil_body_entered(body):
	if body.name == "Alma":  # Asegúrate de usar el nombre correcto del nodo alma
		body.aplicar_dano(20)  # Llamamos a la función del alma para reducir su vida
		queue_free()  # Destruimos el proyectil tras el impacto
