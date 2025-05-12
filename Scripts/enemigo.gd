extends CharacterBody2D

const SPEED = 65
const SPEED_JEFE = 35  

@export var health = 1
@export var es_jefe: bool = false  
@export var pinchos: Node2D = null  # Conectar con los pinchos en la escena

@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var player: CharacterBody2D = null  
@onready var rango_seguir: Area2D = $RangoSeguir
@onready var spawn_timer: Timer = $SpawnTimer

@onready var area_ataque_escena = preload("res://Escenas/area_ataque_jefe.tscn")  
@onready var proyectil_escena = preload("res://Escenas/lanzamiento_ataque_jefe.tscn")  

func _ready():
	if es_jefe:
		health *= 3
		spawn_timer.wait_time = 2.0
		spawn_timer.stop()

		# Si el enemigo es jefe y hay pinchos asignados, los activa
		if pinchos and pinchos.has_method("activate"):
			pinchos.activate()

func _physics_process(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * (SPEED_JEFE if es_jefe else SPEED)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_rango_seguir_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player = body
		spawn_timer.start()

func _on_rango_seguir_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		spawn_timer.stop()

func take_damage():
	health -= 1
	if health <= 0:
		# Cuando el jefe muere, desactivar los pinchos
		if es_jefe and pinchos and pinchos.has_method("deactivate"):
			pinchos.deactivate()
		queue_free()

func _on_spawn_timer_timeout():
	if es_jefe:
		await get_tree().process_frame  # Espera hasta el próximo frame
		spawn_area_ataque()
		spawn_proyectil()

func spawn_area_ataque():
	var area_ataque = area_ataque_escena.instantiate()
	if area_ataque:
		var random_offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		area_ataque.global_position = rango_seguir.global_position + random_offset
		get_parent().add_child(area_ataque)

func spawn_proyectil():
	var proyectil = proyectil_escena.instantiate()
	proyectil.global_position = global_position
	get_parent().add_child(proyectil)

	proyectil.start_attack(player)
