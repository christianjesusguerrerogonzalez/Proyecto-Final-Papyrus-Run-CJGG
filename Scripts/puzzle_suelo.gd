extends Area2D
#Este es puzzle_suelo
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var veces_pisado: int = 0
var completado: bool = false

func reset():
	if not completado:
		veces_pisado = 0
		animated_sprite_2d.animation = "sinpisar"

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D or completado:
		return
	
	if veces_pisado == 0:
		veces_pisado = 1
		animated_sprite_2d.animation = "pisada"
	elif veces_pisado == 1:
		veces_pisado = 2
		animated_sprite_2d.animation = "fallada"
