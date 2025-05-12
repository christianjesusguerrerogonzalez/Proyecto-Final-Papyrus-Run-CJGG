extends RigidBody2D

const FRICTION_FACTOR: float = 0.98
const MIN_SPEED: float = 0.05
var initial_position: Vector2 = Vector2.ZERO
var position_set: bool = false  # Asegura que solo se guarde una vez

func _process(_delta: float) -> void:
	# Guardar la posición solo una vez al principio
	if not position_set:
		initial_position = position
		position_set = true
	
	if linear_velocity.length() < MIN_SPEED:
		linear_velocity = Vector2.ZERO
	else:
		# Determina el eje principal de movimiento
		if abs(linear_velocity.x) > abs(linear_velocity.y):
			linear_velocity = Vector2(linear_velocity.x, 0)  # Movimiento solo en X
		else:
			linear_velocity = Vector2(0, linear_velocity.y)  # Movimiento solo en Y
		
		# Aplica el freno uniformemente
		linear_velocity *= FRICTION_FACTOR

# Función para mover la roca a su posición original
func reset_position():
	position = initial_position
