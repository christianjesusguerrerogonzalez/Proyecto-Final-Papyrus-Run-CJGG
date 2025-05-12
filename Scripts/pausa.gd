extends Control

@onready var panel: Panel = $Panel
@onready var boton_continuar: Button = $Panel/PanelDibujado/Boton_continuar
@onready var boton_salir: Button = $Panel/PanelDibujado/Boton_salir
@onready var panel_estadisticas: Panel = $Panel/PanelDibujado/PanelEstadisticas
@onready var boton_estadisticas: Button = $Panel/PanelDibujado/Boton_estadisticas
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var mision: RichTextLabel = $Panel/PanelDibujado/Mision

# Variables
var panel_visible = false
var estadisticas_visible = false
var dialogo_activo: bool = false  # Nueva variable para detectar si el diálogo está activo

func _ready():
	add_to_group("Pausa")

	# Inicializa el panel invisible
	panel.visible = false
	panel_estadisticas.visible = false

	# Conectar las señales
	boton_continuar.connect("pressed", Callable(self, "_on_boton_continuar_pressed"))
	boton_estadisticas.connect("pressed", Callable(self, "_on_boton_estadisticas_pressed"))
	boton_salir.connect("pressed", Callable(self, "_on_boton_salir_pressed"))

	# Conectar la señal de los diálogos
	for dialogo in get_tree().get_nodes_in_group("dialogos"):
		dialogo.connect("dialogo_activado", Callable(self, "_on_dialogo_activado"))
		print("Conectada señal dialogo_activado desde:", dialogo.name)  # Depuración

	# Buscar los nodos de Misiones en la escena
	await get_tree().process_frame  # Espera 1 frame para asegurar que los nodos existen
	var misiones = get_tree().get_nodes_in_group("Misiones")
	for misionconseguida in misiones:
		misionconseguida.connect("nueva_mision", Callable(self, "_actualizar_mision"))

	print("Nodos de misiones encontrados:", misiones)  # Depuración

	# Configurar detección de teclas
	set_process_input(true)

# Detectar ESC
func _unhandled_input(event):
	# Bloquear entrada si hay un diálogo o cinemática activa
	if GameState.cinematic_active or dialogo_activo:
		return  # Ignorar cualquier entrada mientras hay un diálogo o cinemática

	if event.is_action_pressed("ui_cancel"):  # ESC
		if !panel_visible:
			panel_visible = true
			show_panel()
			get_tree().paused = true  # Pausar el juego
		else:
			panel_visible = false
			hide_panel()
			get_tree().paused = false  # Reanudar el juego

# Manejar el estado del diálogo desde la señal
func _on_dialogo_activado(activo: bool):
	dialogo_activo = activo  # Actualiza la variable local

# Función para actualizar el texto de la misión en el menú de pausa
func _actualizar_mision(mision_texto: String):
	mision.text = mision_texto  # Actualiza el texto de la misión en el menú de pausa

# Función para mostrar el panel
func show_panel():
	panel.visible = true

# Función para esconder el panel
func hide_panel():
	panel.visible = false

# Función para mostrar/ocultar el panel de estadísticas
func _on_boton_estadisticas_pressed():
	if !estadisticas_visible:
		estadisticas_visible = true
		panel_estadisticas.visible = true
		animation_player.play("deslizarderecha") 
		await animation_player.animation_finished
	else:
		animation_player.play("deslizarizquierda")
		await animation_player.animation_finished
		estadisticas_visible = false
		panel_estadisticas.visible = false

# Función para continuar el juego
func _on_boton_continuar_pressed():
	panel.visible = false
	panel_visible = false
	get_tree().paused = false

# Función para salir al menú principal
func _on_boton_salir_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/menuPrincipal.tscn")
