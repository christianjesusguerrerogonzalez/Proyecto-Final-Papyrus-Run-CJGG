extends StaticBody2D
# Pinchos puzzle suelo
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var boton: Area2D # Conectar con BotonPuzzleSuelo

func desactivar():
	animated_sprite_2d.animation = "desactivado"
	get_node("CollisionShape2D").set_deferred("disabled", true)
