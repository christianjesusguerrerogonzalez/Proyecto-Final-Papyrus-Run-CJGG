extends Node2D

@onready var label: Label = $CanvasLayer/Label
@onready var timer: Timer = $CanvasLayer/Timer
@onready var continue_button: Button = $CanvasLayer/continue_button
@onready var exit_button: Button = $CanvasLayer/exit_button
@onready var heart: AnimatedSprite2D = $CanvasLayer/heart  
@onready var game_state = get_node("/root/GameState")  # Referencia al GameState
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

@export var text_to_display: String = "No pierdas la esperanza...,\nMantente determinado!"
@export var speed: float = 0.1  
@export var pause_duration: float = 1
@export var fade_speed: float = 0.5

var current_text: String = ""
var typing_index: int = 0
var is_interacting: bool = false
var fade_alpha: float = 1.0
var selected_button_index: int = 0  

func _ready():
	if continue_button == null:
		print("Error: continue_button no se ha encontrado")
	if exit_button == null:
		print("Error: exit_button no se ha encontrado")
	
	fade_rect.visible = false
	fade_rect.modulate.a = 0  # Asegurar que comience invisible
	
	continue_button.visible = false
	exit_button.visible = false
	heart.visible = false
		
	heart.play("idle")  

	timer.wait_time = speed
	timer.one_shot = false
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	start_typing()

func start_typing():
	current_text = ""
	label.text = current_text
	typing_index = 0
	timer.start() 

func _on_timer_timeout():
	if typing_index < len(text_to_display):
		var char_to_add = text_to_display[typing_index]

		if char_to_add == ',':
			timer.stop()
			await get_tree().create_timer(pause_duration).timeout
			timer.start()
			typing_index += 1  
			return
		
		current_text += char_to_add
		label.text = current_text
		typing_index += 1
	else:
		timer.stop()

func _process(delta):
	if Input.is_action_just_pressed("interactuar") and not is_interacting:
		is_interacting = true
		start_fade_out()

	if is_interacting and fade_alpha > 0:
		fade_alpha -= fade_speed * delta
		label.modulate.a = fade_alpha
		if fade_alpha <= 0:
			label.visible = false
			continue_button.visible = true
			exit_button.visible = true
			heart.visible = true
			update_heart_position()

	if heart.visible:
		handle_selection()

func start_fade_out():
	fade_alpha = 1.0

func handle_selection():
	if Input.is_action_just_pressed("izq"):
		selected_button_index = 0
		update_heart_position()

	elif Input.is_action_just_pressed("der"):
		selected_button_index = 1
		update_heart_position()

	update_button_text_color()

	if Input.is_action_just_pressed("interactuar"):
		if selected_button_index == 0:
			if GameState.has_checkpoint():
				await fade_in()  # Llamamos a la nueva función antes de cargar el checkpoint
			else:
				print("No hay un checkpoint guardado.")
		elif selected_button_index == 1:
			get_tree().quit()

func fade_in():
	fade_rect.visible = true
	fade_rect.modulate.a = 0  # Comienza completamente transparente
	
	var fade_time = 1.0  # Duración del fade-in en segundos
	var elapsed_time = 0.0
	
	while elapsed_time < fade_time:
		elapsed_time += get_process_delta_time()
		fade_rect.modulate.a = elapsed_time / fade_time
		await get_tree().process_frame  # Espera al siguiente frame para hacer el fade suave

	fade_rect.modulate.a = 1  # Asegurar que la opacidad quede en 1
	
	await get_tree().create_timer(0.5).timeout  # Pequeña pausa antes de cargar la escena
	
	await load_last_checkpoint()


func load_last_checkpoint():
	if game_state.has_checkpoint():
		var result = await game_state.load("user://save_test.tres")  # Usamos await
		if result:
			print("Checkpoint cargado correctamente.")
		else:
			print("Error al cargar el checkpoint. Cargando escena predeterminada.")
			get_tree().change_scene_to_file("res://Escenas/LasRuinas.tscn")
	else:
		print("No hay checkpoint guardado. Cargando escena predeterminada.")
		get_tree().change_scene_to_file("res://Escenas/LasRuinas.tscn")

func update_heart_position():
	var button_position = continue_button.position if selected_button_index == 0 else exit_button.position
	heart.position = button_position - Vector2(0, -60)

func update_button_text_color():
	if selected_button_index == 0:
		continue_button.modulate = Color(1, 1, 0)  # Amarillo
		exit_button.modulate = Color(1, 1, 1)  # Blanco
	elif selected_button_index == 1:
		continue_button.modulate = Color(1, 1, 1)  # Blanco
		exit_button.modulate = Color(1, 1, 0)  # Amarillo
