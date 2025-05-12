extends StaticBody2D

var is_active = true
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	activate()  # Los pinchos estarán activados desde el inicio

func activate():
	is_active = true
	call_deferred("_activate_collision")
	animated_sprite_2d.play("activado")

func _activate_collision():
	collision_shape_2d.disabled = false

func deactivate():
	is_active = false
	call_deferred("_deactivate_collision")
	animated_sprite_2d.play("desactivado")

func _deactivate_collision():
	collision_shape_2d.disabled = true
