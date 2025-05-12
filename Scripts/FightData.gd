extends Resource
class_name FightData

@export var scene_name: String = ""
@export var papyrus_position: Vector2 = Vector2.ZERO
@export var items_positions: Dictionary = {
	"Roca": Vector2.ZERO,
	"Roca2": Vector2.ZERO,
	"Roca3": Vector2.ZERO,
	"Tapon": true,  # Estado del primer tapón (activo por defecto)
	"Tapon2": true   # Estado del segundo tapón (activo por defecto)
}
