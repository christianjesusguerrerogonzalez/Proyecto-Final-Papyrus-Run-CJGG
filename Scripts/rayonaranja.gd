extends Area2D

@onready var dañocollision_shape_2d: CollisionShape2D = $dano/CollisionShape2D

var papyrus: Node2D = null  # Guardamos la referencia de Papyrus

func _ready():
	dañocollision_shape_2d.disabled = true  # Desactivamos el daño al principio

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Papyrus":
		papyrus = body  # Guardamos la referencia del cuerpo que entra
		# Si Papyrus está quieto, habilitamos la colisión de daño
		call_deferred("_actualizar_daño")  # Llamamos a _actualizar_daño de manera diferida

func _on_body_exited(body: Node2D) -> void:
	if body == papyrus:
		call_deferred("_desactivar_daño")  # Llamamos a _desactivar_daño de manera diferida
		papyrus = null  # Eliminamos la referencia

func _actualizar_daño() -> void:
	# Comprobamos si Papyrus está quieto
	var velocity = papyrus.velocity
	if velocity.length() == 0:
		dañocollision_shape_2d.disabled = false  # Activa el daño solo si Papyrus está quieto
	else:
		dañocollision_shape_2d.disabled = true  # Desactiva el daño si Papyrus está en movimiento

func _desactivar_daño() -> void:
	dañocollision_shape_2d.disabled = true  # Desactiva el daño al salir del área

func _physics_process(_delta):
	if papyrus and papyrus is CharacterBody2D:  # Aseguramos que es un CharacterBody2D
		var velocity = papyrus.velocity
		dañocollision_shape_2d.disabled = velocity.length() > 0  # Si Papyrus se mueve, desactivamos el daño
