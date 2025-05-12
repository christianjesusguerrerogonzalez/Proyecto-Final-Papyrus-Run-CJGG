extends Area2D

@export var texto: Array = ["Hola, ¿cómo estás?;Bienvenido a nuestra aventura.", "¿Qué elige Papyrus?;Solo el destino lo dirá."]

@onready var panel: Panel = $CanvasLayer/Panel
@onready var timer: Timer = $Timer
@onready var label: RichTextLabel = $CanvasLayer/Panel/RichTextLabel
@onready var collisioninteractuar: CollisionShape2D = $CollisionShape2D

var player_in_interaction_area: bool = false
var typing_index: int = 0
var text_to_display: String = ""
var current_string_index: int = 0
var dialog_active: bool = false

signal interaccion_activada(estado)

func _ready() -> void:
	if not is_in_group("interacciones"):
		add_to_group("interacciones")
	panel.visible = false
	label.text = ""
	panel.size = Vector2(1000, 300)
	panel.position = (get_viewport_rect().size / 2) - (panel.size / 2) + Vector2(0, 250)
	timer.wait_time = 0.05
	timer.one_shot = false
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)


func _process(_delta: float) -> void:
	if player_in_interaction_area and Input.is_action_just_pressed("interactuar"):
		if not dialog_active:
			start_dialog()
		elif typing_index < text_to_display.length():
			display_full_text()
		else:
			advance_dialog()

func _on_collisioninteractuar_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		player_in_interaction_area = true

func _on_collisioninteractuar_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_in_interaction_area = false

func start_dialog():
	dialog_active = true
	panel.visible = true
	current_string_index = 0
	emit_signal("interaccion_activada", true)  # Bloquear el movimiento del personaje
	start_typing()

func start_typing():
	text_to_display = texto[current_string_index].replace(";", "\n")  # Reemplaza ";" por saltos de línea
	label.text = text_to_display
	label.visible_characters = 0
	typing_index = 0
	timer.start()

func _on_timer_timeout():
	if typing_index < text_to_display.length():
		typing_index += 1
		label.visible_characters = typing_index
	else:
		timer.stop()

func advance_dialog():
	current_string_index += 1
	if current_string_index < texto.size():
		start_typing()
	else:
		close_dialog()

func display_full_text():
	timer.stop()
	label.visible_characters = text_to_display.length()
	typing_index = text_to_display.length()

func close_dialog():
	panel.visible = false
	dialog_active = false
	current_string_index = 0  # Reset para permitir reiniciar el diálogo
	emit_signal("interaccion_activada", false)  # Desbloquear el movimiento del personaje
