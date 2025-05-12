extends Area2D
@onready var marker_2d: Marker2D = $Marker2D

func _on_body_entered(body: CharacterBody2D) -> void:
	body.position = marker_2d.global_position
