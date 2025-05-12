extends Area2D

signal tapon_changed_state(tapon_name: String, is_active: bool)  # Define la señal

@export var tapon_path: NodePath
@onready var tapon: Node2D = get_node(tapon_path)
@onready var animacion_interruptor: AnimatedSprite2D = $AnimatedSprite2D
var jugador_en_area: bool = false

func _ready() -> void:
	if not is_in_group("InterruptoresTapones"):
		add_to_group("InterruptoresTapones")
		
		
func _process(_delta: float) -> void:
	if jugador_en_area and Input.is_action_just_pressed("interactuar"):
		if tapon:
			animacion_interruptor.play("activado")
			tapon.call("deactivate") 
			await get_tree().create_timer(0.5).timeout
			animacion_interruptor.play("desactivado")

			# Emitir la señal con el estado actualizado del tapón
			emit_signal("tapon_changed_state", tapon.name, tapon.is_active)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		jugador_en_area = true

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		jugador_en_area = false
