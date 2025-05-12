extends CharacterBody2D

const SPEED = 250.0
@onready var progress_vida: ProgressBar = $CanvasLayer/ProgressVida
@onready var label_vida: Label = $CanvasLayer/LabelVida

# Variable que controla si el alma puede moverse
var puede_moverse = true
var vida_actual = 680  # Vida inicial
var vida_maxima = 680  # Vida máxima

func _ready():
	actualizar_label_vida()  # Inicializamos el label con los valores iniciales
	actualizar_progress_bar()  # También sincronizamos la barra con la vida inicial

func _physics_process(delta: float) -> void:
	if puede_moverse:
		# Movimiento controlado por las teclas de dirección
		var direction := Vector2(
			Input.get_axis("izq", "der"),
			Input.get_axis("arr", "aba")
		)
		velocity = direction.normalized() * SPEED
	else:
		# Si no se puede mover, la velocidad es 0
		velocity = Vector2(0, 0)

	move_and_slide()

# Función para habilitar el movimiento del alma
func habilitar_movimiento():
	puede_moverse = true

# Función para deshabilitar el movimiento del alma
func deshabilitar_movimiento():
	puede_moverse = false

# Función para actualizar la vida del jugador
func aplicar_dano(cantidad: int):
	vida_actual = max(vida_actual - cantidad, 0)  # Nos aseguramos de que la vida no sea menor a 0
	actualizar_label_vida()
	actualizar_progress_bar()

func curar_vida(cantidad: int):
	vida_actual = min(vida_actual + cantidad, vida_maxima)  # Nos aseguramos de no exceder la vida máxima
	actualizar_label_vida()
	actualizar_progress_bar()

# Función para actualizar el texto del label
func actualizar_label_vida():
	label_vida.text = "HP: %d/%d" % [vida_actual, vida_maxima]

func actualizar_progress_bar():
	progress_vida.value = float(vida_actual) / float(vida_maxima) * 680
