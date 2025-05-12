extends Area2D

@export var speed: float = 300
@onready var sprite: Sprite2D = $Hueso
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var bone_direction: Vector2 = Vector2.ZERO

func _ready():
	# Configuramos el timer para que el hueso desaparezca tras 2 segundos
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timeout"))
	add_child(timer)
	timer.start()


func _process(delta: float) -> void:
	position += bone_direction.normalized() * speed * delta

func _on_timeout() -> void:
	queue_free()  # Eliminar el hueso después del tiempo

func set_bone_direction(direction: Vector2):
	bone_direction = direction

# Se llama cuando un cuerpo entra en el área del hueso
func _on_body_entered(body: Node2D):
	# Verificamos si el cuerpo es un enemigo con un hitbox (CollisionShape2D)
	if body is CharacterBody2D:
		# Si el cuerpo es un enemigo y tiene un método para recibir daño
		if body.has_method("take_damage"):
			body.take_damage()  # Aplicamos el daño al enemigo
			queue_free()  # Eliminar el hueso al golpear
