extends Node2D

@export var textos_pelea: Array = ["¡Prepárate para luchar!", "¡Vamos a por todas!", "¡Es tu turno, actúa!"]

@onready var alma: CharacterBody2D = $Alma
@onready var fight: Button = $Fight
@onready var mercy: Button = $Mercy
@onready var primer_ataque_froggit: PackedScene = preload("res://Escenas/primer_ataque_froggit.tscn")
@onready var audio_boton: AudioStreamPlayer2D = $Fight/AudioBoton
@onready var label_texto_pelea: RichTextLabel = $LabelTextoPelea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var barra_vida_froggit: ProgressBar = $Froggit/BarraVidaFroggit
@onready var label_dano: Label = $Froggit/LabelDano

@onready var animated_sprite_2d: AnimatedSprite2D = $Alma/AnimatedSprite2D
@onready var progress_vida: ProgressBar = $Alma/CanvasLayer/ProgressVida

var vida_froggit = 50  # Vida inicial del enemigo
var vida_maxima_froggit = 50

@onready var barra_mercy_froggit: ProgressBar = $Froggit/BarraMercyFroggit
var mercy_actual = 0  # Valor inicial de la barra Mercy
var mercy_maxima = 100  # Valor máximo de la barra Mercy


var turno_jugador = true
var turno_enemigo = false
var ataques_restantes = 0
var ataque_actual = 0
var posicion_fight = Vector2(56, 816)
var posicion_mercy = Vector2(853, 816)
var tiempo_espera_proyectiles_linea = 0.8
var tiempo_espera_proyectiles_seguir = 2.0
var timer_proyectil: Timer = null
var escribiendo_texto = false  # Bandera para controlar la escritura
var animacion_activa = false  # Bandera para controlar las animaciones
var probabilidades_ataques = [0.33, 0.33, 0.33]
var combate_activo = true

signal encounter_finished  # Señal para notificar el final del combate

func _ready():
	alma.position = posicion_fight  # Asegurarse de que el corazón comience en la posición de "Fight"
	alma.puede_moverse = false  # Desactivar movimiento al inicio
	animacion_activa = true  # Activar bandera de animación
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))  # Conectar señal
	animation_player.play("EntrandoPelea")  # Reproducir animación inicial
	barra_vida_froggit.visible = false
	label_dano.visible = false

func _process(delta):
	if !combate_activo:  # Si el combate ha terminado, no hacer nada
		return
	if !animacion_activa:
		if turno_jugador:
			control_turno_jugador()
		elif turno_enemigo:
			control_turno_enemigo(delta)

#////////////////////////////////////////////CONTROLADORES DE TURNOS///////////////////////////////////////////////////	
func control_turno_jugador():
	if animacion_activa:  # Bloquear controles si hay animación activa
		return
	# Movimiento entre botones Fight y Mercy
	if Input.is_action_just_pressed("ui_right") and alma.position == posicion_fight:
		audio_boton.play()
		alma.position = posicion_mercy
	elif Input.is_action_just_pressed("ui_left") and alma.position == posicion_mercy:
		audio_boton.play()
		alma.position = posicion_fight
	# Ejecutar acción en el botón seleccionado
	if Input.is_action_just_pressed("interactuar"):
		if alma.position == posicion_fight:
			iniciar_fight()  # Acción Fight
		elif alma.position == posicion_mercy:
			activar_mercy()  # Acción Mercy
			# Comprobar si la barra de Mercy está llena
			if mercy_actual == mercy_maxima:
				mostrar_mensaje_perdon()  # Mostrar mensaje de perdón
				return  # Finalizar flujo si se llena Mercy
		# Comprobar si Froggit ha sido derrotado antes de continuar
		if vida_froggit <= 0:
			enemigo_derrotado()  # Manejar derrota del enemigo
			return  # Finalizar flujo si Froggit está derrotado
		# Movimiento a posición central y preparar turno enemigo
		alma.position = Vector2(566, 298)  # Movimiento a posición central
		turno_jugador = false
		limpiar_texto_pelea()
		iniciar_turno_enemigo()

func iniciar_turno_enemigo():
	if vida_froggit <= 0:
		enemigo_derrotado()  # Llama al método de derrota sin reproducir animación
		return
	if mercy_actual >= mercy_maxima:  # Comprobar si la barra está llena
		mostrar_mensaje_perdon()  # Detener combate si está llena
		return
	turno_enemigo = true
	animacion_activa = true  # Activar bandera de animación
	alma.puede_moverse = false  # Bloquear movimiento mientras inicia el turno del enemigo


func _on_terminar_animacion_salida(anim_name):
	if anim_name == "SaliendoPelea":
		limpiar_texto_pelea()  # Borrar texto
		alma.puede_moverse = true  # Permitir movimiento si el turno enemigo requiere interactuar


func control_turno_enemigo(delta):
	if !combate_activo:  # Si el combate terminó, no procesar
		return
	match ataque_actual:
		0: ataque_lanzar_proyectiles_linea(delta)
		1: ataque_seguir_jugador(delta)
		2: pass
	# No detener el turno del enemigo aunque el jugador haya muerto.
	if ataques_restantes <= 0:
		finalizar_turno_enemigo()
	comprobar_vida_jugador()

func finalizar_turno_enemigo():
	if vida_froggit <= 0:  # Comprobar si Froggit ha sido derrotado
		enemigo_derrotado()  # Llama al método de derrota sin reproducir animación
		return

	turno_enemigo = false
	turno_jugador = true
	animacion_activa = true  # Activar bandera de animación
	alma.puede_moverse = false  # Bloquear movimiento hasta que termine la animación
	animation_player.play("EntrandoPelea")  # Reproducir animación de entrada
	eliminar_todos_los_ataques()
	alma.position = posicion_fight  # Restaurar posición inicial del corazón
	limpiar_texto_pelea()  # Limpiamos cualquier texto previo


func iniciar_fight():
	alma.puede_moverse = false  # Bloquear el movimiento del jugador
	turno_jugador = false  # Bloquear el turno del jugador
	# Temporizador para aplicar daño
	var timer_pre_dano = Timer.new()
	timer_pre_dano.wait_time = 1.0  # Esperar 1 segundo antes de aplicar el daño
	timer_pre_dano.one_shot = true
	add_child(timer_pre_dano)
	timer_pre_dano.connect("timeout", Callable(self, "_aplicar_dano_froggit"))
	timer_pre_dano.start()


func eliminar_todos_los_ataques():
	for child in get_children():
		if child is Area2D and child.has_method("iniciar_ataque"):
			child.queue_free()

#////////////////////////////////////TEXTOS, TIMERS Y ANIMACIONES////////////////////////////////////////
func escribir_texto_pelea():
	if !escribiendo_texto:  # Solo escribir si no hay animación en curso
		escribiendo_texto = true
		label_texto_pelea.text = textos_pelea[randi() % textos_pelea.size()]
		label_texto_pelea.visible_characters = 0
		var timer = Timer.new()
		timer.wait_time = 0.05
		timer.one_shot = false
		add_child(timer)
		timer.connect("timeout", Callable(self, "_incrementar_visible_characters"))
		timer.start()

func _incrementar_visible_characters():
	if label_texto_pelea.visible_characters < label_texto_pelea.text.length():
		label_texto_pelea.visible_characters += 1
	else:
		# Detener la animación al llegar al final
		escribiendo_texto = false


func limpiar_texto_pelea():
	label_texto_pelea.visible_characters = 0  # Eliminar caracteres visibles
	label_texto_pelea.text = ""  # Reiniciar el texto completo


func _on_timer_proyectil_timeout():
	if ataques_restantes > 0:
		var proyectil = primer_ataque_froggit.instantiate()
		proyectil.position = Vector2(randf_range(207, 856), randf_range(23, 27))
		proyectil.iniciar_ataque(300.0, false)
		add_child(proyectil)
		ataques_restantes -= 1
	if ataques_restantes <= 0:
		timer_proyectil.stop()
		timer_proyectil.queue_free()
		finalizar_turno_enemigo()


func _on_animation_finished(anim_name):
	if anim_name == "EntrandoPelea" or anim_name == "SaliendoPelea":
		animacion_activa = false  # Desactivar bandera de animación
		if anim_name == "EntrandoPelea":
			escribir_texto_pelea()  # Ejecutar la escritura del texto solo al terminar la animación de entrada
		if anim_name == "SaliendoPelea":
			alma.puede_moverse = true  # Permitir movimiento después de que finalice "SaliendoPelea"
			# Iniciar lógica de ataques aquí, después de la animación
			ataque_actual = elegir_ataque()
			match ataque_actual:
				0: ataques_restantes = 15
				1: ataques_restantes = 5
				2: ataques_restantes = 25
			if ataque_actual == 2:
				timer_proyectil = Timer.new()
				timer_proyectil.wait_time = 0.5
				timer_proyectil.one_shot = false
				add_child(timer_proyectil)
				timer_proyectil.connect("timeout", Callable(self, "_on_timer_proyectil_timeout"))
				timer_proyectil.start()

#/////////////////////////////////////////////FROGGIT//////////////////////////////////////////////////////////////////
func _aplicar_dano_froggit():
	luchar()  # Aplicar el daño al enemigo
	if vida_froggit > 0:  # Solo continuar si el enemigo no ha sido derrotado
		animation_player.play("SaliendoPelea")  # Reproducir animación de salida
		iniciar_turno_enemigo()  # Pasar al turno del enemigo

func _completar_ataque():
	if vida_froggit <= 0:  # Comprobar si Froggit ha sido derrotado
		enemigo_derrotado()  # Manejar la derrota sin animación
	else:
		animation_player.play("SaliendoPelea")  # Reproducir la animación de salida
		iniciar_turno_enemigo()  # Pasar al turno del enemigo


func ataque_lanzar_proyectiles_linea(delta):
	tiempo_espera_proyectiles_linea += delta
	if tiempo_espera_proyectiles_linea >= 0.8 and ataques_restantes > 0:
		tiempo_espera_proyectiles_linea = 0.0
		var proyectil = primer_ataque_froggit.instantiate()
		proyectil.position = Vector2(randf_range(198, 914), randf_range(48, 581))
		var direccion = (alma.position - proyectil.position).normalized()
		proyectil.iniciar_ataque(300.0, false)
		proyectil.custom_direction = direccion
		add_child(proyectil)
		ataques_restantes -= 1

func ataque_seguir_jugador(delta):
	tiempo_espera_proyectiles_seguir += delta
	if tiempo_espera_proyectiles_seguir >= 2.0 and ataques_restantes > 0:
		tiempo_espera_proyectiles_seguir = 0.0
		var proyectil = primer_ataque_froggit.instantiate()
		proyectil.position = Vector2(randf_range(198, 914), randf_range(48, 581))
		proyectil.iniciar_ataque(200.0, true)
		add_child(proyectil)
		ataques_restantes -= 1
	if ataques_restantes <= 0:
		finalizar_turno_enemigo()

func _continuar_pelea():
	if vida_froggit <= 0:  # Comprobar si el enemigo ha sido derrotado
		enemigo_derrotado()  # Finalizar sin animación si Froggit ha sido derrotado
		return



func elegir_ataque():
	var ataque = randf_range(0.0, 1.0)
	if ataque < probabilidades_ataques[0]:
		probabilidades_ataques[0] -= 0.1
		probabilidades_ataques[1] += 0.05
		probabilidades_ataques[2] += 0.05
		return 0
	elif ataque < probabilidades_ataques[0] + probabilidades_ataques[1]:
		probabilidades_ataques[1] -= 0.1
		probabilidades_ataques[0] += 0.05
		probabilidades_ataques[2] += 0.05
		return 1
	else:
		probabilidades_ataques[2] -= 0.1
		probabilidades_ataques[0] += 0.05
		probabilidades_ataques[1] += 0.05
		return 2

func luchar():
	if barra_vida_froggit.visible == false:
		barra_vida_froggit.visible = true  # Mostrar la barra de vida del enemigo
		label_dano.visible = true  # Mostrar el label del daño
	# Calcular daño con las probabilidades dadas
	var random = randf()
	var porcentaje_dano = 0.0
	if random <= 0.5:
		porcentaje_dano = 0.1  # 10% de vida
	elif random <= 0.8:
		porcentaje_dano = 0.2  # 20% de vida
	elif random <= 0.95:
		porcentaje_dano = 0.5  # 50% de vida
	else:
		porcentaje_dano = 0.75  # 75% de vida
	# Calcular daño y aplicar a la vida del enemigo
	var dano = int(vida_maxima_froggit * porcentaje_dano)
	vida_froggit = max(vida_froggit - dano, 0)  # La vida no puede ser menor a 0
	# Mostrar barra de vida y el daño
	actualizar_barra_vida_enemigo()
	mostrar_dano(dano)
	# Si Froggit tiene 0 HP, mostrar barra y daño antes de cambiar escena
	if vida_froggit <= 0:
		enemigo_derrotado()
	# Temporizador para ocultar barra y label después de un segundo
	var timer_ocultar = Timer.new()
	timer_ocultar.wait_time = 1.0
	timer_ocultar.one_shot = true
	add_child(timer_ocultar)
	timer_ocultar.connect("timeout", Callable(self, "_ocultar_barra_y_label"))
	timer_ocultar.start()
	# Comprobamos si el enemigo fue derrotado
	if vida_froggit <= 0:
		enemigo_derrotado()

func _ocultar_barra_y_label():
	barra_vida_froggit.visible = false
	label_dano.visible = false

func actualizar_barra_vida_enemigo():
	barra_vida_froggit.value = float(vida_froggit) / float(vida_maxima_froggit) * 50  # Porcentaje de vida

func mostrar_dano(dano: int):
	label_dano.text = "-%d HP" % dano
	label_dano.visible = true
	# Hacemos que desaparezca el daño después de un tiempo
	var timer = Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_ocultar_dano"))
	timer.start()

func enemigo_derrotado():
	turno_jugador = true  # Permitir que el turno vuelva al jugador
	turno_enemigo = false  # Finalizar el turno del enemigo
	animacion_activa = false  # Detener cualquier animación activa
	alma.puede_moverse = false  # Desactivar el movimiento
	# Escribir "¡Has ganado!" en el LabelTextoPelea
	label_texto_pelea.text = "¡Has ganado!"
	label_texto_pelea.visible = true
	# Esperar 1.5 segundos antes de cambiar de escena
	var timer_cambiar_escena = Timer.new()
	timer_cambiar_escena.wait_time = 1.5
	timer_cambiar_escena.one_shot = true
	add_child(timer_cambiar_escena)
	timer_cambiar_escena.connect("timeout", Callable(self, "_cambiar_escena"))
	timer_cambiar_escena.start()

func _cambiar_escena():
	# Cambiar de vuelta a la escena original, Las Ruinas
	get_tree().change_scene_to_file("res://Escenas/LasRuinas.tscn")

	# Cargar datos para restaurar posiciones
	var loaded_data = PositionSave.load_from_file()
	if loaded_data:
		PositionSave.apply_loaded_data()
	else:
		print("Error: No se pudieron cargar los datos de la escena guardada.")


#///////////////////////////////////JUGADOR/////////////////////////////////////////////

func comprobar_vida_jugador():
	if progress_vida.value <= 0:  # Si la vida es 0 o menor
		animacion_activa = true  # Para evitar cualquier otra interacción
		alma.puede_moverse = false  # Bloquear el movimiento del jugador
		animated_sprite_2d.play("Muerte")  # Reproducir la animación de muerte
		animated_sprite_2d.connect("animation_finished", Callable(self, "_al_terminar_animacion_muerte"))

func _al_terminar_animacion_muerte():
	get_tree().change_scene_to_file("res://Escenas/game_over.tscn")  # Cambia la ruta de tu escena.
	
#////////////////////////////////////////PERDONAR////////////////////////////////////////////////
func activar_mercy():
	mercy_actual += 20
	mercy_actual = min(mercy_actual, mercy_maxima)  # Asegurar que no pase del máximo
	barra_mercy_froggit.value = mercy_actual
	if mercy_actual >= mercy_maxima:
		mostrar_mensaje_perdon()  # Se detiene el combate aquí
		return  # Evita que el turno enemigo inicie
	# Iniciar turno enemigo y animación si la barra no está llena
	alma.position = Vector2(566, 298)  # Mover el corazón a la posición central
	turno_jugador = false
	animacion_activa = true  # Activar bandera de animación
	animation_player.play("SaliendoPelea")  # Reproducir animación de salida
	limpiar_texto_pelea()
	iniciar_turno_enemigo()


func _incrementar_barra_mercy():
	mercy_actual += 20  # Incrementar la barra de Mercy
	mercy_actual = min(mercy_actual, mercy_maxima)  # Limitar al máximo
	actualizar_barra_mercy()


func actualizar_barra_mercy():
	barra_mercy_froggit.value = mercy_actual  # Actualiza el valor de la barra en la interfaz

func mostrar_mensaje_perdon():
	combate_activo = false
	turno_jugador = true  # Bloquear el turno del jugador
	turno_enemigo = false  # Detener el turno del enemigo
	animacion_activa = true  # Detener cualquier animación activa
	alma.puede_moverse = false  # Desactivar el movimiento
	label_texto_pelea.text = "¡Has perdonado al enemigo!"  # Mostrar el mensaje final
	label_texto_pelea.visible = true

	# Temporizador para cambiar de escena
	var timer_cambiar_escena = Timer.new()
	timer_cambiar_escena.wait_time = 1.5  # Esperar 1.5 segundos antes de cambiar de escena
	timer_cambiar_escena.one_shot = true
	add_child(timer_cambiar_escena)
	timer_cambiar_escena.connect("timeout", Callable(self, "_cambiar_escena"))
	timer_cambiar_escena.start()
