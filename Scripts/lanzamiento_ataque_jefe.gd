extends Area2D

@export var speed: float = 200  # Velocidad inicial
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var bone_direction: Vector2 = Vector2.ZERO
var time_alive: float = 0.0  # Tiempo de vida del proyectil
var is_moving: bool = false  # Se mueve solo después de 0.8s

func _ready():
	# Timer para desaparecer después de 3s
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timeout"))
	add_child(timer)
	timer.start()

func _process(delta: float) -> void:
	if is_moving:
		time_alive += delta
		var current_speed = speed * pow(3, time_alive)  # Aumenta exponencialmente
		position += bone_direction.normalized() * current_speed * delta


func _on_timeout() -> void:
	queue_free()

func start_attack(target: Node2D):
	await get_tree().create_timer(0.8).timeout  # Espera 0.8s sin moverse
	if target:
		bone_direction = (target.global_position - global_position).normalized()
		rotation = bone_direction.angle() + PI / 2 # Se rota en la dirección correcta
	is_moving = true  # Ahora sí empieza a moverse

func _on_body_entered(body: Node2D):
	if body is CharacterBody2D and body.has_method("take_damage"):
		body.take_damage()
		queue_free()
