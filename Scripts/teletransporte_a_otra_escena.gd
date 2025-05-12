extends Area2D

@export var escena_teletransportada: PackedScene
@onready var fade_rect: ColorRect = $"../../TransicionNegro/ColorRect"
@onready var papyrus: CharacterBody2D = $"../../Papyrus"

var teletransporteactivo: bool
var fade_speed = 0.8
var fading_out = false

signal tele_activado(teletransporteactivo)

func _ready():
	if not is_in_group("tps"):
		add_to_group("tps")

	fade_rect.size = get_viewport().size
	fade_rect.modulate.a = 0
	fade_rect.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Papyrus" and not fading_out:
		teletransporteactivo = true
		emit_signal("tele_activado", teletransporteactivo)
		start_teleport()

func start_teleport() -> void:
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

		if escena_teletransportada:
			get_tree().change_scene_to_packed(escena_teletransportada)
		else:
			print("Error: No se ha asignado una escena objetivo.")
