extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var marker: Marker2D = $Marker2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dañocollision_shape_2d: CollisionShape2D = $"daño/CollisionShape2D"

var timer: Timer
var estado_activo: bool = true
var tiempo_activo = 3.0
var tiempo_desactivado = 1.0

func _ready():
	timer = Timer.new()
	timer.wait_time = tiempo_activo
	timer.connect("timeout", Callable(self,"_on_timer_timeout" ))
	add_child(timer)
	timer.start()

	animated_sprite.play("parado")

func _on_body_entered(body: Node2D) -> void:
	if estado_activo and body.name == "Papyrus":
		body.global_position = marker.global_position

func _on_timer_timeout() -> void:
	estado_activo = not estado_activo

	if estado_activo:
		collision_shape.disabled = false
		dañocollision_shape_2d.disabled = false
		animated_sprite.play("parado")
		timer.wait_time = tiempo_activo
	else:
		collision_shape.disabled = true
		dañocollision_shape_2d.disabled = true
		animated_sprite.play("desactivado")
		timer.wait_time = tiempo_desactivado

	timer.start()
