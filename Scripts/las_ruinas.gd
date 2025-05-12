extends Node2D

func _ready() -> void:
	print("Inicio ruinas: ",Time.get_ticks_msec())
	add_to_group("gameplay")  # Añadir el nodo al grupo de gameplay
	
	# Conectar interruptores de tapones al evento de cambio de estado
	for interruptor in get_tree().get_nodes_in_group("InterruptoresTapones"):
		if not interruptor.is_connected("tapon_changed_state", Callable(self, "_on_tapon_changed_state")):
			interruptor.connect("tapon_changed_state", Callable(self, "_on_tapon_changed_state"))

	# Verificar si el archivo de guardado existe
	if FileAccess.file_exists("res://fight_save.tres"):  # RUTA DEL ARCHIVO
		PositionSave.start_load_process()
		await get_tree().process_frame  # Esperar un frame para evitar errores de carga
		# Si los datos son válidos, restaurar estados
		if PositionSave.items_positions and "Tapon" in PositionSave.items_positions and "Tapon2" in PositionSave.items_positions:
			_restaurar_tapones()
		else:
			print("⚠️ Advertencia: Datos de guardado vacíos o incompletos.")
	else:
		print("⚠️ No se encontró el archivo de guardado, iniciando sin datos previos.")

	print("Fin ruinas: ",Time.get_ticks_msec())

# Restaura el estado de los tapones
func _restaurar_tapones() -> void:
	if has_node("Tapones/Tapon"):
		var tapon_1 = get_node("Tapones/Tapon")
		if tapon_1 and tapon_1.has_method("activate") and tapon_1.has_method("deactivate"):
			if PositionSave.items_positions.get("Tapon", false):
				tapon_1.call("activate")
			else:
				tapon_1.call("deactivate")

	if has_node("Tapones/Tapon2"):
		var tapon_2 = get_node("Tapones/Tapon2")
		if tapon_2 and tapon_2.has_method("activate") and tapon_2.has_method("deactivate"):
			if PositionSave.items_positions.get("Tapon2", false):
				tapon_2.call("activate")
			else:
				tapon_2.call("deactivate")

# Maneja cambios de estado de los tapones
func _on_tapon_changed_state(tapon_name: String, is_active: bool) -> void:
	if not PositionSave.items_positions:
		return

	if tapon_name in PositionSave.items_positions:
		PositionSave.items_positions[tapon_name] = is_active
		PositionSave.save_to_file()
	else:
		print("⚠️ Advertencia: Nombre de tapón desconocido:", tapon_name)
