extends Area2D

@export var teleport_position: Vector2
@export var player_path: NodePath
var player

func _ready():
	player = get_node(player_path)

func _on_body_entered(body: Node) -> void:
	if body.name == "Papyrus":
		player.global_position = teleport_position
