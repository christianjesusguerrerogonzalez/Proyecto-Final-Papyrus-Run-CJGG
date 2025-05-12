extends Area2D

@onready var dano: CollisionShape2D = $dano/CollisionShape2D

var papyrus: CharacterBody2D = null  # Guardamos la referencia de Papyrus


func _ready():
	dano.disabled = true  # Desactivamos el daño al principio
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Papyrus":
		papyrus = body
		call_deferred("_actualizar_daño")

func _on_body_exited(body: Node2D) -> void:
	if body == papyrus:
		call_deferred("_desactivar_daño")
		papyrus = null  # Eliminamos la referencia

func _actualizar_daño() -> void:
	# Comprobamos si Papyrus está quieto
	var velocity = papyrus.velocity
	if velocity.length() != 0:
		dano.disabled = false  # Activa el daño solo si Papyrus está quieto
	else:
		dano.disabled = true  # Desactiva el daño si Papyrus está en movimiento

func _desactivar_daño() -> void:
	dano.disabled = true  # Desactiva el daño al salir del área
