extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var animacion_activada = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: CharacterBody2D):
	if body.name == "Papyrus" and not animacion_activada:
		animated_sprite_2d.play("Desaparece")
		animacion_activada=true
