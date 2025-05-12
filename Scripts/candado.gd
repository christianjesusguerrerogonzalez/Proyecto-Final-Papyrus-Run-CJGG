extends Node2D

@export var pinchos: Node2D  # Ahora puedes elegir los pinchos en el inspector

var codigo_correcto = []  # Código basado en las cantidades generadas
var codigo_actual = [0, 0, 0]  # Los números inician en 0
var indice_actual = 0  # Índice del número seleccionado (0: Antorchas, 1: Árboles, 2: Bolas)
var jugador_puede_moverse = false  # Bloquea el movimiento al inicio

@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var numero_antorchas: Label = $CanvasLayer/NumeroAntorchas
@onready var numero_arboles: Label = $CanvasLayer/NumeroArboles
@onready var numero_bolas: Label = $CanvasLayer/NumeroBolas

func _ready():
	canvas_layer.visible = false  # Inicialmente, el candado está invisible

func mostrar_candado(cantidad_antorchas, cantidad_arboles, cantidad_bolas_nieve):
	codigo_correcto = [cantidad_antorchas, cantidad_arboles, cantidad_bolas_nieve]
	canvas_layer.visible = true
	jugador_puede_moverse = true  # Permite mover los números solo cuando el candado esté activo
	actualizar_labels()

func ocultar_candado():
	canvas_layer.visible = false
	jugador_puede_moverse = false  # Bloquea el movimiento de los números

	# Permitir nuevamente el movimiento de Papyrus
	var papyrus = get_tree().get_root().get_node("Snowdin/Papyrus")
	if papyrus:
		papyrus.set_physics_process(true)
	else:
		print("Error: No se encontró el nodo 'Papyrus'.")

func actualizar_labels():
	numero_antorchas.text = str(codigo_actual[0])
	numero_arboles.text = str(codigo_actual[1])
	numero_bolas.text = str(codigo_actual[2])

func validar_codigo():
	if codigo_actual == codigo_correcto:
		print("¡Código correcto!")
		if pinchos:  # Verifica que los pinchos hayan sido asignados
			pinchos.deactivate()  # Desactiva los pinchos al ingresar el código correcto
	else:
		print("¡Código incorrecto!")
	ocultar_candado()  # Cierra el candado después de validar

func _input(event):
	if jugador_puede_moverse:  # Solo permite interacción si el candado está activo
		if event.is_action_pressed("ui_up"):  # Aumentar número
			codigo_actual[indice_actual] = min(codigo_actual[indice_actual] + 1, 9)
			actualizar_labels()
		elif event.is_action_pressed("ui_down"):  # Disminuir número
			codigo_actual[indice_actual] = max(codigo_actual[indice_actual] - 1, 0)
			actualizar_labels()
		elif event.is_action_pressed("ui_right"):  # Mover a la derecha
			indice_actual = (indice_actual + 1) % 3
		elif event.is_action_pressed("ui_left"):  # Mover a la izquierda
			indice_actual = (indice_actual - 1) % 3
		elif event.is_action_pressed("interactuar"):  # Validar código con Z
			validar_codigo()
