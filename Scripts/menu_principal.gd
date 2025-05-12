extends Control

@onready var papyrus: CharacterBody2D = $"../Papyrus"
@onready var color_rect: ColorRect = $ColorRect
@onready var heart: AnimatedSprite2D = $heart
@onready var play_button: Button = $play_button
@onready var reset_button: Button = $reset_button
@onready var game_state = get_node("/root/GameState")  # Referencia al GameState
@onready var fade_rect: ColorRect = $FadeRect
@onready var exit_audio: AudioStreamPlayer2D = $ExitAudio

var fade_speed = 0.2  # Ralentizar la velocidad del fade para hacerlo más lento
var fading_out = false
var selected_button_index = 0  # 0 = play_button, 1 = reset_button
var reset_mode = false
var can_select_buttons = true  # Nueva variable para controlar la selección de botones

func _ready():
	# Configuración inicial
	play_button.focus_mode = Control.FOCUS_NONE
	reset_button.focus_mode = Control.FOCUS_NONE
	play_button.modulate = Color(1, 1, 0)
	reset_button.modulate = Color(1, 1, 1)
	heart.visible = true
	update_heart_position()
	fade_rect.modulate.a = 0  # Hace que el fade rect sea invisible al inicio

func _process(delta):
	# Cambiar selección del botón con teclas izquierda y derecha
	if can_select_buttons:  # Solo permite la selección si está habilitada
		if Input.is_action_just_pressed("ui_left"):
			selected_button_index = max(0, selected_button_index - 1)
			update_heart_position()
			play_button.modulate = Color(1, 1, 0)
			reset_button.modulate = Color(1, 1, 1)
		elif Input.is_action_just_pressed("ui_right"):
			selected_button_index = min(1, selected_button_index + 1)
			update_heart_position()
			reset_button.modulate = Color(1, 1, 0)
			play_button.modulate = Color(1, 1, 1)

	# Ejecutar acción con interactuar (Z)
	if Input.is_action_just_pressed("interactuar") and not fading_out:
		can_select_buttons = false  # Deshabilita la navegación al iniciar una acción
		exit_audio.play()  # Reproduce el sonido antes de hacer el fade
		if selected_button_index == 0:  # Play Button
			start_fade_out(false)
		elif selected_button_index == 1:  # Reset Button
			start_fade_out(true)

	# Animación de desvanecimiento
	if fading_out:
		fade_rect.modulate.a += fade_speed * delta
		if fade_rect.modulate.a >= 1:
			fade_rect.modulate.a = 1
			if reset_mode:
				reset_game_state_continue()
			else:
				# Usar `await` para esperar correctamente en el ciclo de vida de la escena
				await get_tree().process_frame
				await load_last_checkpoint()

func update_heart_position():
	# Actualiza la posición del corazón según el botón seleccionado
	var button_position = play_button.position if selected_button_index == 0 else reset_button.position
	heart.position = button_position - Vector2(-10, -60)  # Ajusta según tu diseño

func start_fade_out(is_reset):
	fade_rect.visible = true  # Asegúrate de que el fade rect sea visible al empezar
	fading_out = true
	reset_mode = is_reset

func reset_game_state():
	# Comprueba si existe el archivo antes de iniciar el fade
	var checkpoint_path = "user://save_test.tres"
	if FileAccess.file_exists(checkpoint_path):
		start_fade_out(true)  # Si el archivo existe, inicia el fade para reset
	else:
		print("No hay archivo de checkpoint para reiniciar.")  # No hace nada si no hay checkpoint
		can_select_buttons = true  # Permite volver a moverse entre botones

func reset_game_state_continue():
	# Reinicia el archivo del checkpoint y carga la escena inicial
	var checkpoint_path = "user://save_test.tres"
	if FileAccess.file_exists(checkpoint_path):
		var dir_access = DirAccess.open("user://")
		if dir_access and dir_access.file_exists("save_test.tres"):
			dir_access.remove("save_test.tres")
			print("Checkpoint reiniciado.")
		else:
			print("No se pudo acceder al archivo.")
	else:
		print("No hay archivo de checkpoint para reiniciar.")
	can_select_buttons = true  # Vuelve a habilitar la selección
	get_tree().change_scene_to_file("res://Escenas/animacionintro.tscn")

func load_last_checkpoint():
	# Carga el último checkpoint desde el archivo guardado
	if game_state.has_checkpoint():
		var result = await game_state.load("user://save_test.tres")
		if result:
			print("Checkpoint cargado correctamente.")
		else:
			print("Error al cargar el checkpoint. Cargando escena predeterminada.")
			get_tree().change_scene_to_file("res://Escenas/animacionintro.tscn")
	else:
		print("No hay checkpoint guardado. Cargando escena predeterminada.")
		can_select_buttons = true  # Vuelve a habilitar la selección
		get_tree().change_scene_to_file("res://Escenas/animacionintro.tscn")

# Añadimos un método para asegurarnos que cuando se cambie de escena, la selección se vuelve a habilitar
func _notification(what):
	if what == NOTIFICATION_READY:
		can_select_buttons = true  # Reactiva la selección de botones al cambiar de escena
