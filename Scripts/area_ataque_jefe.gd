extends Area2D

@export var fade_duration = 0.5  # Duración de aparición y desaparición
@export var lifetime = 2.0      # Tiempo total de vida del área antes de eliminarse

@onready var timer: Timer = $Timer  # Temporizador para controlar el tiempo de vida

func _ready():
	# Configurar la transparencia inicial
	modulate.a = 0.0  # Opacidad inicial (completamente transparente)
	fade_in()

	# Configurar el temporizador para comenzar la desaparición después del tiempo de vida
	timer.wait_time = lifetime
	timer.start()

func fade_in():
	# Incrementar opacidad progresivamente para hacer que aparezca
	var elapsed_time = 0.0
	while elapsed_time < fade_duration:
		elapsed_time += 0.016  # Aproximadamente 1 frame (asumiendo 60 FPS)
		modulate.a = elapsed_time / fade_duration
	modulate.a = 1.0  # Asegurar que la opacidad sea totalmente visible

func fade_out():
	# Reducir opacidad progresivamente para hacer que desaparezca
	var elapsed_time = 0.0
	while elapsed_time < fade_duration:
		elapsed_time += 0.016  # Aproximadamente 1 frame
		modulate.a = 1.0 - (elapsed_time / fade_duration)
	modulate.a = 0.0  # Asegurar que quede completamente transparente
	queue_free()  # Eliminar el área de ataque

func _on_Timer_timeout():
	fade_out()  # Inicia el efecto de desaparición cuando el temporizador termine
