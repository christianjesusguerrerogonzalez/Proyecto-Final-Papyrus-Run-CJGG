extends Control

@onready var intro_sprites = [
	$Intro1, $Intro2, $Intro3, $Intro4, $Intro5, $Intro6
]
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer
@onready var color_rect: ColorRect = $ColorRect

@export var textos: Array[String] = []
@export var texto_speed: float = 0.08  # Velocidad del texto
@export var fade_speed: float = 0.1  # Velocidad del fade in del ColorRect
@export var wait_time: float = 3.0  # Tiempo a esperar antes de avanzar

var current_index = 0
var visible_characters = 0
var is_text_complete = false
var timer_accumulator = 0.0
var fade_accumulator = 0.0  # Para controlar la aparición del ColorRect
var is_fading = false  # Controla el estado del fade
var wait_accumulator = 0.0  # Para el tiempo de espera

func _ready():
	for i in range(intro_sprites.size()):
		intro_sprites[i].visible = (i == 0)  # Solo el primero es visible

	if textos.size() > 0:
		rich_text_label.text = textos[0].replace(";", "\n")  # Reemplazar los puntos y coma por saltos de línea
		rich_text_label.set_visible_characters(0)  # No mostrar ningún carácter al principio

	# Inicializar ColorRect con opacidad 0
	color_rect.modulate.a = 0

func _process(delta):
	if !is_text_complete and visible_characters < rich_text_label.text.length():
		timer_accumulator += delta
		if timer_accumulator >= texto_speed:
			visible_characters += 1
			rich_text_label.set_visible_characters(visible_characters)
			timer_accumulator = 0.0  # Reiniciar el temporizador
	elif visible_characters == rich_text_label.text.length():
		is_text_complete = true
		wait_accumulator += delta
		if wait_accumulator >= wait_time:
			advance_intro()

	# Si estamos en el proceso de hacer aparecer el ColorRect
	if is_fading:
		fade_accumulator += delta
		if fade_accumulator < fade_speed:
			color_rect.modulate.a = fade_accumulator / fade_speed
		else:
			color_rect.modulate.a = 1  # Aseguramos que la opacidad llegue a 1
			# Cambiar de escena si el ColorRect está completamente visible
			if fade_accumulator >= fade_speed:
				get_tree().change_scene_to_file("res://Escenas/LasRuinas.tscn")

func advance_intro():
	if current_index < intro_sprites.size() - 1:
		intro_sprites[current_index].visible = false
		current_index += 1
		intro_sprites[current_index].visible = true

		# Cambia el texto en el RichTextLabel
		if current_index < textos.size():
			rich_text_label.text = textos[current_index].replace("CAYÓ EL ESQUELETO MÁS GENIAL;DEL MUNDO!", "[shake]CAYÓ EL ESQUELETO MÁS GENIAL;DEL MUNDO![/shake]").replace(";", "\n")
			rich_text_label.set_visible_characters(0)  # Iniciar con el texto vacío
			visible_characters = 0  # Reiniciar el contador de caracteres visibles
			is_text_complete = false  # Resetear la condición de texto completo
			wait_accumulator = 0.0  # Reiniciar el acumulador de espera
	else:
		# Iniciar el fade del ColorRect
		is_fading = true
