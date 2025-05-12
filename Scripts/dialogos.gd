extends Area2D

@export var texto: Array = ["Hola, ¿cómo estás?", "¿Qué elige Papyrus?"]
@export var boton_opcion_1: String = "Camino 1"
@export var boton_opcion_2: String = "Camino 2"
@export var opcion1: Array = ["Este es el camino 1.", "Sigue avanzando.", "Final del camino 1."]
@export var opcion2: Array = ["Este es el camino 2.", "Hay una bifurcación más adelante.", "Final del camino 2."]
@export var dialog_id: String = ""  # ID único para el diálogo

@onready var panel: Panel = $CanvasLayer/Panel
@onready var timer: Timer = $Timer
@onready var label: RichTextLabel = $CanvasLayer/Panel/RichTextLabel
@onready var boton_1: Button = $CanvasLayer/Panel/BotonOpcion1
@onready var boton_2: Button = $CanvasLayer/Panel/BotonOpcion2
@onready var charavoice: AudioStreamPlayer2D = $charavoice
@onready var clovervoice: AudioStreamPlayer2D = $clovervoice
@onready var genericvoice: AudioStreamPlayer2D = $genericvoice

var player_in_area: bool = false
var typing_index: int = 0
var text_to_display: String = ""
var text_displayed: bool = false
var menu_activo: bool = false
var current_string_index: int = 0
var dialogo_completado: bool = false
var opciones_activas: bool = false
var selected_button_index: int = 0
var ruta_dialogo: Array = []

signal dialogo_activado(dialogo_activo)

func _ready() -> void:
	if dialog_id != "" and PositionSave and PositionSave.dialogo_ya_leido(dialog_id):
		dialogo_completado = true  # Marcar como completado para que no se muestre
		print("El diálogo ya fue leído:", dialog_id)
	if not is_in_group("dialogos"):
		add_to_group("dialogos")
	panel.visible = false
	label.text = ""
	panel.size = Vector2(1000, 300)
	panel.position = (get_viewport_rect().size / 2) - (panel.size / 2) + Vector2(0, 250)
	timer.wait_time = 0.05
	timer.one_shot = false
	timer.autostart = false
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	boton_1.visible = false
	boton_2.visible = false
	boton_1.text = boton_opcion_1
	boton_2.text = boton_opcion_2

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and not dialogo_completado:
		InputMap.action_erase_events("cerrar")
		player_in_area = true
		menu_activo = true
		emit_signal("dialogo_activado", menu_activo)
		GameState.cinematic_active = true  # Bloquear el menú de pausa

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_in_area = false
		menu_activo = false
		emit_signal("dialogo_activado", menu_activo)
		GameState.cinematic_active = false  # Desbloquear el menú de pausa

func _process(_delta: float) -> void:
	if player_in_area and not text_displayed:
		panel.visible = true
		start_typing()
		text_displayed = true

	if player_in_area:
		if Input.is_action_just_pressed("interactuar"):
			if typing_index < text_to_display.length():
				display_full_text()
			elif opciones_activas:
				if Input.is_action_just_pressed("interactuar"):  # "Z" para elegir
					handle_button_selection()
			else:
				advance_dialog()

		if opciones_activas:
			if Input.is_action_just_pressed("ui_left"):  # Flecha izquierda
				selected_button_index = 0
				update_button_colors()
			elif Input.is_action_just_pressed("ui_right"):  # Flecha derecha
				selected_button_index = 1
				update_button_colors()

func start_typing():
	var temp_text = texto[current_string_index]

	# Determinar si es un diálogo de CHARA o CLOVER
	var is_chara_dialogue = "*CHARA*" in temp_text
	var is_clover_dialogue = "*CLOVER*" in temp_text
	var is_generic_dialogue = "*GENERIC*" in temp_text

	# Reemplazar nombres con etiquetas de color y reproducir la voz correcta
	if is_chara_dialogue:
		label.add_theme_color_override("default_color", Color.RED)
		temp_text = temp_text.replace("*CHARA*", "")
		charavoice.play()  # Sonido de Chara
	elif is_clover_dialogue:
		label.add_theme_color_override("default_color", Color.YELLOW)
		temp_text = temp_text.replace("*CLOVER*", "")
		clovervoice.play()  # Sonido de Clover
	elif is_generic_dialogue:
		label.add_theme_color_override("default_color", Color.WHITE)
		temp_text = temp_text.replace("*GENERIC*", "")
		genericvoice.play()  # Sonido genérico

	# Aplicar efectos de texto
	text_to_display = temp_text.replace("Frisk", "[shake][color=red]Frisk[/color]").replace(";", "\n")
	label.text = text_to_display
	label.visible_characters = 0
	typing_index = 0
	timer.start()

func _on_timer_timeout():
	if typing_index < text_to_display.length():
		typing_index += 1
		label.visible_characters = typing_index
	else:
		timer.stop()
		charavoice.stop()
		clovervoice.stop()
		genericvoice.stop()

func advance_dialog():
	if texto[current_string_index] == "*GENERIC*¿Qué elige Papyrus?":
		show_options()
	else:
		current_string_index += 1
		if current_string_index < texto.size():
			start_typing()
		elif ruta_dialogo:
			texto = ruta_dialogo
			ruta_dialogo = []
			current_string_index = 0
			start_typing()
		else:
			dialogo_completado = true
			close_dialog()

func show_options():
	opciones_activas = true
	label.text = ""
	boton_1.visible = true
	boton_2.visible = true
	selected_button_index = 0  # Por defecto empieza en el primer botón
	update_button_colors()

func handle_button_selection():
	opciones_activas = false
	boton_1.visible = false
	boton_2.visible = false

	# Elegir el diálogo dependiendo del botón seleccionado
	if selected_button_index == 0:
		texto = opcion1  # Opción 1 seleccionada
	elif selected_button_index == 1:
		texto = opcion2  # Opción 2 seleccionada

	# Reiniciar el índice para empezar desde el primer mensaje de la opción seleccionada
	current_string_index = 0
	start_typing()

func display_full_text():
	timer.stop()
	label.visible_characters = text_to_display.length()
	typing_index = text_to_display.length()
	charavoice.stop()
	clovervoice.stop()
	genericvoice.stop()

func close_dialog():
	panel.visible = false
	text_displayed = false
	menu_activo = false
	dialogo_completado = true
	player_in_area = false
	emit_signal("dialogo_activado", menu_activo)
	GameState.cinematic_active = false  # Desbloquear el menú de pausa

	# Marcar el diálogo como leído en PositionSave
	if dialog_id != "" and PositionSave:
		PositionSave.marcar_dialogo_leido(dialog_id)


	var cerrar_event = InputEventKey.new()
	cerrar_event.physical_keycode = Key.KEY_X
	InputMap.action_add_event("cerrar", cerrar_event)

func update_button_colors():
	if selected_button_index == 0:
		boton_1.add_theme_color_override("font_color", Color.YELLOW)
		boton_1.add_theme_color_override("border_color", Color.YELLOW)
		boton_1.modulate = Color(1, 1, 0)
		boton_2.add_theme_color_override("font_color", Color.WHITE)
		boton_2.add_theme_color_override("border_color", Color.WHITE)
		boton_2.modulate = Color(1, 1, 1)
	else:
		boton_1.add_theme_color_override("font_color", Color.WHITE)
		boton_1.add_theme_color_override("border_color", Color.WHITE)
		boton_1.modulate = Color(1, 1, 1)
		boton_2.add_theme_color_override("font_color", Color.YELLOW)
		boton_2.add_theme_color_override("border_color", Color.YELLOW)
		boton_2.modulate = Color(1, 1, 0)
