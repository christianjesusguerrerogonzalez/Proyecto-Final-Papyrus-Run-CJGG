extends Area2D

@onready var fade_rect: ColorRect = $"../../TransicionNegro/ColorRect"
@onready var punto_de_teletransporte: Marker2D = $PuntoDeTeletransporte
@onready var papyrus: CharacterBody2D = $"../../Papyrus"

var teletransporteactivo: bool
var fade_speed = 0.8
var fading_out = false

signal tele_activado(teletransporteactivo)

func _ready():
	if not is_in_group("tps"):
		add_to_group("tps")
		
	# Hacer que el fade cubra toda la pantalla
	fade_rect.anchor_left = 0
	fade_rect.anchor_top = 0
	fade_rect.anchor_right = 1
	fade_rect.anchor_bottom = 1
	
	fade_rect.offset_left = 0
	fade_rect.offset_top = 0
	fade_rect.offset_right = 0
	fade_rect.offset_bottom = 0

	fade_rect.modulate.a = 0
	fade_rect.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Papyrus" and not fading_out:
		teletransporteactivo = true
		emit_signal("tele_activado", teletransporteactivo)
		GameState.cinematic_active = true  # Bloquear el menú de pausa

		start_teleport(body)

func start_teleport(body: CharacterBody2D) -> void:
	if Input.is_action_just_pressed("cerrar"):
		return
	else: 
		InputMap.action_erase_events("cerrar")
		fading_out = true
		fade_rect.visible = true
		emit_signal("tele_activado", true)  # Detener movimiento

		while fade_rect.modulate.a < 1:
			fade_rect.modulate.a += fade_speed * get_process_delta_time()
			await get_tree().process_frame

		body.position = punto_de_teletransporte.global_position

		while fade_rect.modulate.a > 0:
			fade_rect.modulate.a -= fade_speed * get_process_delta_time()
			await get_tree().process_frame

		fade_rect.visible = false
		fading_out = false

		emit_signal("tele_activado", false)  # Reanudar movimiento
		GameState.cinematic_active = false  # Bloquear el menú de pausa

		# Crear un nuevo evento de input para 'cerrar'
		var cerrar_event = InputEventKey.new()
		cerrar_event.physical_keycode = Key.KEY_X  # Asegúrate de que este sea el código correcto para 'x'
		InputMap.action_add_event("cerrar", cerrar_event)
