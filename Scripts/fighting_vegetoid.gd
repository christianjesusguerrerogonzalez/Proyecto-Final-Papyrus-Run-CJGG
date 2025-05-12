extends Node2D

@export var textos_pelea: Array = ["¡Prepárate para luchar!", "¡Vamos a por todas!", "¡Es tu turno, actúa!"]

@onready var alma: CharacterBody2D = $Alma
@onready var fight: Button = $Fight
@onready var mercy: Button = $Mercy
@onready var primer_ataque_vegetoid: PackedScene = preload("res://Escenas/primer_ataque_vegetoid.tscn")
@onready var primer_cura_vegetoid: PackedScene = preload("res://Escenas/primer_cura_vegetoid.tscn")
@onready var audio_boton: AudioStreamPlayer2D = $Fight/AudioBoton
@onready var label_texto_pelea: RichTextLabel = $LabelTextoPelea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var barra_vida_vegetoid: ProgressBar = $Vegetoid/BarraVidaVegetoid
@onready var label_dano: Label = $Vegetoid/LabelDano

@onready var animated_sprite_2d: AnimatedSprite2D = $Alma/AnimatedSprite2D
@onready var progress_vida: ProgressBar = $Alma/CanvasLayer/ProgressVida

var vida_vegetoid = 72  # Vida inicial del enemigo
var vida_maxima_vegetoid = 72

@onready var barra_mercy_vegetoid: ProgressBar = $Vegetoid/BarraMercyVegetoid
var mercy_actual = 0  # Valor inicial de la barra Mercy
var mercy_maxima = 100  # Valor máximo de la barra Mercy


var turno_jugador = true
var turno_enemigo = false
var ataques_restantes = 0
var ataque_actual = 0
var posicion_fight = Vector2(56, 816)
var posicion_mercy = Vector2(853, 816)
var timer_proyectil: Timer = null
var escribiendo_texto = false  # Bandera para controlar la escritura
var animacion_activa = false  # Bandera para controlar las animaciones
var combate_activo = true
var proyectiles_generados = 0
var timer_proyectiles: Timer = null
var probabilidades_ataques = [0.5, 0.5]  # Dividimos las probabilidades entre dos ataques.
var ataque_en_proceso = false  # Nueva bandera

signal encounter_finished  # Señal para notificar el final del combate

func _ready():
	alma.position = posicion_fight  # Asegurarse de que el corazón comience en la posición de "Fight"
	alma.puede_moverse = false  # Desactivar movimiento al inicio
	animacion_activa = true  # Activar bandera de animación
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))  # Conectar señal
	animation_player.play("EntrandoPelea")  # Reproducir animación inicial
	barra_vida_vegetoid.visible = false
	label_dano.visible = false

func _process(delta):
	if !combate_activo:
		return
	if !animacion_activa:
		if turno_jugador:
			control_turno_jugador()
		elif turno_enemigo:
			control_turno_enemigo(delta)
	comprobar_vida_jugador()

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
		if vida_vegetoid <= 0:
			enemigo_derrotado()  # Manejar derrota del enemigo
			return  # Finalizar flujo si Froggit está derrotado
		# Movimiento a posición central y preparar turno enemigo
		alma.position = Vector2(566, 298)  # Movimiento a posición central
		turno_jugador = false
		limpiar_texto_pelea()
		iniciar_turno_enemigo()

func iniciar_turno_enemigo():
	eliminar_todos_los_ataques()
	if vida_maxima_vegetoid <= 0:
		enemigo_derrotado()
		return
	if mercy_actual >= mercy_maxima:
		mostrar_mensaje_perdon()
		return

	turno_enemigo = true
	animacion_activa = true
	alma.puede_moverse = false
	ataque_en_proceso = false  # Asegurarse de reiniciar la bandera de ataque


func _on_terminar_animacion_salida(anim_name):
	if anim_name == "SaliendoPelea":
		limpiar_texto_pelea()  # Borrar texto
		alma.puede_moverse = true  # Permitir movimiento si el turno enemigo requiere interactuar

func control_turno_enemigo(delta):
	if ataque_en_proceso:  # Si ya estamos ejecutando un ataque, no hacer nada
		return
	ataque_en_proceso = true  # Bloquea la ejecución de nuevos ataques hasta que este termine
	match ataque_actual:
		0: ataque_rebotes()
		1: ataque_caida_rapida()
	if ataques_restantes <= 0:
		finalizar_turno_enemigo()
		ataque_en_proceso = false  # Liberar la bandera para el próximo turno
	comprobar_vida_jugador()

func finalizar_turno_enemigo():
	# Limpia proyectiles y temporizadores
	eliminar_todos_los_ataques()
	if timer_proyectiles != null:
		timer_proyectiles.stop()
		timer_proyectiles.queue_free()
		timer_proyectiles = null
	proyectiles_generados = 0  # Reinicia proyectiles
	# Cambia al turno del jugador
	turno_enemigo = false
	turno_jugador = true
	animacion_activa = true  # Bloquea acciones mientras inicia el turno del jugador
	alma.puede_moverse = false
	animation_player.play("EntrandoPelea")  # Animación para la transición
	alma.position = posicion_fight  # Reinicia la posición del jugador
	limpiar_texto_pelea()

func iniciar_fight():
	alma.puede_moverse = false  # Bloquear el movimiento del jugador
	turno_jugador = false  # Bloquear el turno del jugador
	
		# Temporizador para aplicar daño
	var timer_pre_dano = Timer.new()
	timer_pre_dano.wait_time = 1.0  # Esperar 1 segundo antes de aplicar el daño
	timer_pre_dano.one_shot = true
	add_child(timer_pre_dano)
	timer_pre_dano.connect("timeout", Callable(self, "_aplicar_dano_vegetoid"))
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


func _on_animation_finished(anim_name):
	if anim_name == "EntrandoPelea" or anim_name == "SaliendoPelea":
		animacion_activa = false  # Desactivar bandera de animación
		if anim_name == "EntrandoPelea":
			escribir_texto_pelea()
		if anim_name == "SaliendoPelea":
			alma.puede_moverse = true
			eliminar_todos_los_ataques()
			# Limpia temporizadores y proyectiles existentes
			if timer_proyectiles != null:
				timer_proyectiles.stop()
				timer_proyectiles.queue_free()
				timer_proyectiles = null
			proyectiles_generados = 0  # Reinicia el contador de proyectiles

			# Asigna el siguiente ataque
			ataque_actual = elegir_ataque()
			match ataque_actual:
				0: ataques_restantes = 10
				1: ataques_restantes = 18


#/////////////////////////////////////////////VEGETOID//////////////////////////////////////////////////////////////////
func _aplicar_dano_vegetoid():
	luchar()  # Aplicar el daño al enemigo
	if vida_vegetoid > 0:  # Solo continuar si el enemigo no ha sido derrotado
		animation_player.play("SaliendoPelea")  # Reproducir animación de salida
		iniciar_turno_enemigo()  # Pasar al turno del enemigo

func _completar_ataque():
	if vida_vegetoid <= 0:
		enemigo_derrotado()
	else:
		animation_player.play("SaliendoPelea")
		iniciar_turno_enemigo()

func ataque_rebotes():
	var proyectiles_generados = 0
	var total_proyectiles = 10
	while proyectiles_generados < total_proyectiles:
		# Crear proyectil
		var proyectil = primer_ataque_vegetoid.instantiate()
		# Asignar posición aleatoria en izquierda o derecha
		if randf() < 0.5:
			proyectil.position = Vector2(233, randi_range(59, 267))  # Rango en la izquierda
		else:
			proyectil.position = Vector2(910, randi_range(59, 267))  # Rango en la derecha
		# Asignar dirección inicial y otras propiedades
		proyectil.custom_direction = Vector2(-1, 1)  # Movimiento hacia abajo y hacia un lado
		proyectil.gravedad = 100.0  # Gravedad inicial para simular el salto
		# Conectar evento para manejar rebotes y colisiones laterales
		proyectil.connect("area_entered", Callable(self, "_manejar_rebote").bind(proyectil))
		add_child(proyectil)
		# Incrementar contador de proyectiles
		proyectiles_generados += 1
		# Esperar un momento antes de generar el siguiente proyectil
		await get_tree().create_timer(0.8).timeout
	# Llamar a finalizar_turno_enemigo cuando todos los proyectiles hayan sido creados
	finalizar_turno_enemigo()



func _manejar_rebote(proyectil, area):
	# Rebote al tocar el borde inferior
	if proyectil.position.y >= 579:
		proyectil.custom_direction.y = -1  # Cambiar dirección hacia arriba

	# Rebote en bordes laterales
	if proyectil.position.x <= 229 or proyectil.position.x >= 919:
		proyectil.custom_direction.x *= -1  # Cambiar dirección horizontal


func ataque_caida_rapida():
	proyectiles_generados = 0  # Reiniciar contador al comenzar el ataque
	var total_proyectiles = 25  # Total de proyectiles a generar

	# Crear una lista con 20 ataques y 5 curas
	var lista_proyectiles = []
	for i in range(20):
		lista_proyectiles.append(primer_ataque_vegetoid)
	for i in range(5):
		lista_proyectiles.append(primer_cura_vegetoid)

	# Mezclar aleatoriamente la lista
	lista_proyectiles.shuffle()

	# Crear un temporizador para manejar la caída uno a uno
	var timer_caida = Timer.new()
	timer_caida.wait_time = 0.8  # Cooldown de 0.8 segundos entre cada proyectil
	timer_caida.one_shot = false
	add_child(timer_caida)

	# Conectar el temporizador al método de generación de proyectiles
	timer_caida.connect("timeout", Callable(self, "_generar_proyectil_caida").bind(timer_caida, lista_proyectiles))
	timer_caida.start()

func _generar_proyectil_caida(timer_caida, lista_proyectiles):
	# Verificar si ya se generaron todos los proyectiles
	if proyectiles_generados >= lista_proyectiles.size():
		timer_caida.stop()
		timer_caida.queue_free()
		finalizar_turno_enemigo()  # Finaliza el turno inmediatamente
		return
	
	# Obtener el siguiente tipo de proyectil en la lista aleatoria
	var tipo_proyectil = lista_proyectiles[proyectiles_generados]
	var proyectil = tipo_proyectil.instantiate()
	proyectil.position = Vector2(randf_range(229, 919), 49)  # Coordenadas aleatorias desde el borde superior
	proyectil.iniciar_ataque(false, Vector2(0, 1))  # Configurar movimiento inicial
	proyectil.gravedad = 500.0  # Configurar gravedad rápida para la caída
	add_child(proyectil)

	# Incrementar el contador global de proyectiles generados
	proyectiles_generados += 1



func _continuar_pelea():
	if vida_vegetoid <= 0:  # Comprobar si el enemigo ha sido derrotado
		enemigo_derrotado()  # Finalizar sin animación si Froggit ha sido derrotado
		return

func elegir_ataque():
	var ataque = randf_range(0.0, 1.0)
	if ataque < probabilidades_ataques[0]:
		return 0
	else:
		return 1

func luchar():
	if barra_vida_vegetoid.visible == false:
		barra_vida_vegetoid.visible = true  # Mostrar la barra de vida del enemigo
		label_dano.visible = true  # Mostrar el label del daño
	# Generar daño basado en las probabilidades
	var random = randf()  # Genera un número flotante entre 0 y 1
	var dano = 0
	if random <= 0.6:
		dano = 20  # 60% probabilidad
	elif random <= 0.6 + 0.5:
		dano = 25  # 50% probabilidad
	elif random <= 0.6 + 0.5 + 0.3:
		dano = 40  # 30% probabilidad
	else:
		dano = 50  # 10% probabilidad (crítico)
	vida_vegetoid = max(vida_vegetoid - dano, 0)  # La vida no puede ser menor a 0
	# Mostrar barra de vida y el daño
	actualizar_barra_vida_enemigo()
	mostrar_dano(dano)
	# Si Vegetoid tiene 0 HP, manejamos la derrota antes de cambiar escena
	if vida_vegetoid <= 0:
		enemigo_derrotado()
	# Temporizador para ocultar barra y label después de un segundo
	var timer_ocultar = Timer.new()
	timer_ocultar.wait_time = 1.0
	timer_ocultar.one_shot = true
	add_child(timer_ocultar)
	timer_ocultar.connect("timeout", Callable(self, "_ocultar_barra_y_label"))
	timer_ocultar.start()



func _ocultar_barra_y_label():
	barra_vida_vegetoid.visible = false
	label_dano.visible = false

func actualizar_barra_vida_enemigo():
	barra_vida_vegetoid.value = float(vida_vegetoid) / float(vida_maxima_vegetoid) * 72  # Porcentaje de vida


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
		if animated_sprite_2d.is_connected("animation_finished", Callable(self, "_al_terminar_animacion_muerte")):
			animated_sprite_2d.disconnect("animation_finished", Callable(self, "_al_terminar_animacion_muerte"))
		animated_sprite_2d.connect("animation_finished", Callable(self, "_al_terminar_animacion_muerte"))


func _al_terminar_animacion_muerte():
	get_tree().change_scene_to_file("res://Escenas/game_over.tscn")  # Cambia la ruta de tu escena.
	
#////////////////////////////////////////PERDONAR////////////////////////////////////////////////
func activar_mercy():
	mercy_actual += 20  # Incrementamos en 50 puntos
	mercy_actual = min(mercy_actual, mercy_maxima)  # Asegurar que no pase del máximo
	barra_mercy_vegetoid.value = mercy_actual
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
	barra_mercy_vegetoid.value = mercy_actual  # Actualiza el valor de la barra en la interfaz

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
