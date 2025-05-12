extends Node2D

signal nueva_mision(mision_texto: String)  # <-- Señal para enviar el texto de la misión

@export var mision_text: String = "Nueva Misión Activada!"
@onready var mision_label: RichTextLabel = $Area2D/CanvasLayer/Mision
var mision_mostrada: bool = false
@onready var misiones: Sprite2D = $Area2D/CanvasLayer/Misiones

func _ready():
	mision_label.visible = false
	misiones.visible = false

func _on_body_entered(body):
	if body.name == "Papyrus" and not mision_mostrada:
		mision_mostrada = true
		emit_signal("nueva_mision", mision_text)  
		
		# Asegurar que el menú de pausa también reciba la misión
		var pausa = get_tree().get_first_node_in_group("Pausa")
		if pausa:
			pausa._actualizar_mision(mision_text)

		await mostrar_mision()


func mostrar_mision():
	mision_label.text = mision_text
	mision_label.visible = true
	misiones.visible = true
	mision_label.modulate.a = 0.0
	misiones.modulate.a = 0.0
	var fade_in_time = 1.0
	var elapsed = 0.0

	while elapsed < fade_in_time:
		elapsed += get_process_delta_time()
		mision_label.modulate.a = elapsed / fade_in_time
		misiones.modulate.a = elapsed / fade_in_time
		await get_tree().process_frame

	mision_label.modulate.a = 1.0
	misiones.modulate.a = 1.0
	await get_tree().create_timer(5.0).timeout
	await ocultar_mision()

func ocultar_mision():
	var fade_out_time = 1.0
	var elapsed = 0.0

	while elapsed < fade_out_time:
		elapsed += get_process_delta_time()
		mision_label.modulate.a = 1.0 - (elapsed / fade_out_time)
		misiones.modulate.a = 1.0 - (elapsed / fade_out_time)
		await get_tree().process_frame

	mision_label.visible = false
	misiones.visible = false
