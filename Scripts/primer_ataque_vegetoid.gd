extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var custom_direction: Vector2 = Vector2.ZERO  # Dirección del movimiento
var follow_player: bool = false  # Propiedad para seguir al jugador
var tiempo_vida: float = 5.0  # Tiempo de vida del proyectil
var gravedad: float = 50.0  # Valor de gravedad aplicado al movimiento

func _ready() -> void:
	var animaciones = ["Cebolla", "Mazorca", "Patata", "Platano", "Tomate", "Zanahoria"]
	var animacion_aleatoria = animaciones[randi() % animaciones.size()]
	animated_sprite_2d.play(animacion_aleatoria)  # Reproducir animación aleatoria

func iniciar_ataque(seguir: bool = false, direccion_inicial: Vector2 = Vector2.ZERO):
	follow_player = seguir
	custom_direction = direccion_inicial

	if not follow_player:
		# Si no sigue al jugador, define dirección hacia abajo
		custom_direction = Vector2(0, 1)

func _process(delta: float):
	# Movimiento del proyectil
	position += custom_direction * delta * gravedad
	# Simular efecto de gravedad
	custom_direction.y += 1 * delta  # Incremento gradual en la dirección vertical
	# Rebote cuando llega al borde inferior
	if position.y >= 579:  # Verificar borde inferior
		position.y = 579  # Ajustar posición para que no pase el borde
		custom_direction.y = -1  # Cambiar dirección hacia arriba
	# Rebote en bordes laterales (229 y 919)
	if position.x <= 229 or position.x >= 919:
		custom_direction.x *= -1  # Cambiar dirección horizontal
	tiempo_vida -= delta
	if tiempo_vida <= 0.0:
		queue_free()  # Destruye el proyectil tras su tiempo de vida

	if follow_player:
		var alma = get_parent().get_node("Alma")  # Nodo del jugador
		if alma:
			var direccion = (alma.position - position).normalized()
			position += direccion * gravedad * delta  # Mover hacia el jugador
	else:
		# Movimiento basado en dirección inicial
		position += custom_direction * gravedad * delta


# Nueva función: Manejo de colisión con el alma
func _on_proyectil_body_entered(body):
	if body.name == "Alma":  # Asegúrate de usar el nombre correcto del nodo alma
		body.aplicar_dano(75)  # Llamamos a la función del alma para reducir su vida
		queue_free()  # Destruimos el proyectil tras el impacto
		
