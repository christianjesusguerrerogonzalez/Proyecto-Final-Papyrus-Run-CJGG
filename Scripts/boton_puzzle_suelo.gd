extends Area2D
# Este es boton_puzzle_suelo
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var suelos: Array[Area2D] # Conectar con los PuzzleSuelo
@export var pinchos: Array[StaticBody2D] # Conectar con los PinchosPuzzleSuelo

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D:
		return
	
	animated_sprite_2d.animation = "pisada"
	var completado = true
	for suelo in suelos:
		if suelo.animated_sprite_2d.animation != "pisada":
			completado = false
			break

	if completado:
		for suelo in suelos:
			suelo.animated_sprite_2d.animation = "completado"
			suelo.completado = true
		for pincho in pinchos:
			pincho.desactivar()
	else:
		for suelo in suelos:
			suelo.reset()

func _on_body_exited(_body: Node2D) -> void:
	animated_sprite_2d.play("sinpisar")
