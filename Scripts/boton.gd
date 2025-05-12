extends Area2D

@export var pinchos_node_path: NodePath

func _on_area_entered(_area: Area2D) -> void:
	if has_node(pinchos_node_path):
		var pinchos = get_node(pinchos_node_path)
		pinchos.deactivate()

func _on_area_exited(_area: Area2D) -> void:
	if has_node(pinchos_node_path):
		var pinchos = get_node(pinchos_node_path)
		pinchos.activate()
