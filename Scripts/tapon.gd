extends Node2D

var is_active = true
@onready var tapon: Sprite2D = $"."
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

func activate():
	is_active = true
	call_deferred("_enable_collision")
	tapon.visible = true

func deactivate():
	is_active = false
	call_deferred("_disable_collision")
	tapon.visible = false

func _enable_collision():
	if collision_shape_2d:
		collision_shape_2d.disabled = false 
		
func _disable_collision():
	if collision_shape_2d:
		collision_shape_2d.disabled = true
