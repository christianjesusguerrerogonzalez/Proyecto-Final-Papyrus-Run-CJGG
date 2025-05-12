extends Area2D

@export var camera_2d: Camera2D

func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		camera_2d.zoom = Vector2(6, 6) 
		
func _on_area_2d_body_exited(body):
	if body is CharacterBody2D:
		camera_2d.zoom = Vector2(4, 4) 
