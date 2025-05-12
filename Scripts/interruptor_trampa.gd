extends Area2D

@onready var marker: Marker2D = $Marker2D
@onready var animacion_interruptor: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_daño: Area2D = $"daño"

var jugador_en_area: bool = false
var teletransporte: bool = false

func _ready() -> void:
	area_daño.collision_mask = 0

func _process(_delta: float) -> void:
	# Verificar si el jugador está en el área y presiona la tecla de interacción
	if jugador_en_area and Input.is_action_just_pressed("interactuar") and not teletransporte:
		activar_damage()

func activar_damage() -> void:
	teletransporte = true
	animacion_interruptor.play("activado")
	area_daño.collision_mask = 2
	await get_tree().create_timer(1).timeout
	animacion_interruptor.play("desactivado")
	area_daño.collision_mask = 0

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		jugador_en_area = true
		if teletransporte:
			body.global_position = marker.global_position
			teletransporte = false

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		jugador_en_area = false
