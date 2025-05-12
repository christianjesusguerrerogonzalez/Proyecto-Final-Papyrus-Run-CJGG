extends Area2D

@export var roca_node_path: NodePath
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var player_in_area: bool = false

func _process(_delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("interactuar"): 
		if has_node(roca_node_path):
			var roca = get_node(roca_node_path) as RigidBody2D
			animated_sprite_2d.play("activado")
			roca.reset_position()  
			await get_tree().create_timer(0.5).timeout
			animated_sprite_2d.play("desactivado")

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:  
		player_in_area = true

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_in_area = false
