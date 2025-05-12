extends Node

var papyrus_position: Vector2 = Vector2.ZERO
var current_scene_path: String = ""
var items_positions: Dictionary = {}
var dialogos_leidos: Array = []  # Lista de IDs de diálogos leídos

# Guardar posiciones y la escena actual usando FightData
func save_position_and_scene(scene_name: String, papyrus_pos: Vector2, roca_pos: Vector2, roca_2_pos: Vector2, roca_3_pos: Vector2, tapon1_state: bool, tapon2_state: bool) -> void:
	current_scene_path = "res://Escenas/" + scene_name + ".tscn"
	papyrus_position = papyrus_pos

	# Asegurar que los estados de los tapones estén incluidos en el diccionario
	items_positions = {
		"Roca": roca_pos,
		"Roca2": roca_2_pos,
		"Roca3": roca_3_pos,
		"Tapon": tapon1_state,  # Estado del primer tapón
		"Tapon2": tapon2_state  # Estado del segundo tapón
	}

	var fight_data = FightData.new()
	fight_data.scene_name = current_scene_path
	fight_data.papyrus_position = papyrus_position
	fight_data.items_positions = items_positions

	ResourceSaver.save(fight_data, "user://fight_save.tres")

# Marcar un diálogo como leído
func marcar_dialogo_leido(dialog_id: String):
	if not dialogos_leidos.has(dialog_id):  # Evitar duplicados
		dialogos_leidos.append(dialog_id)
		guardar_dialogos_leidos()

# Verificar si un diálogo ya fue leído
func dialogo_ya_leido(dialog_id: String) -> bool:
	return dialog_id in dialogos_leidos

# Guardar los diálogos leídos en un archivo
func guardar_dialogos_leidos():
	var file = FileAccess.open("user://dialogos_leidos.save", FileAccess.WRITE)
	if file:
		file.store_var(dialogos_leidos)  # Guardar la lista de IDs
		file.close()

# Cargar los diálogos leídos desde un archivo
func cargar_dialogos_leidos():
	if FileAccess.file_exists("user://dialogos_leidos.save"):
		var file = FileAccess.open("user://dialogos_leidos.save", FileAccess.READ)
		if file:
			dialogos_leidos = file.get_var()  # Elimina el argumento inválido
			file.close()


# Guardar los datos si son válidos usando FightData
func save_to_file():
	if current_scene_path != "" and papyrus_position != Vector2.ZERO:
		var fight_data = FightData.new()
		fight_data.scene_name = current_scene_path
		fight_data.papyrus_position = papyrus_position
		fight_data.items_positions = items_positions

		ResourceSaver.save(fight_data, "user://fight_save.tres")
	else:
		print("Error: Datos incompletos para guardar.")

func load_from_file() -> bool:
	if not FileAccess.file_exists("user://fight_save.tres"):
		save_default_fight_data()
	
	var resource = ResourceLoader.load("user://fight_save.tres")
	if resource:
		current_scene_path = resource.scene_name
		papyrus_position = resource.papyrus_position
		items_positions = resource.items_positions
		return true
	else:
		return false

func save_default_fight_data():
	var fight_data = FightData.new()
	fight_data.scene_name = "res://Escenas/LasRuinas.tscn"
	fight_data.papyrus_position = Vector2.ZERO
	fight_data.items_positions = {
		"Roca": Vector2.ZERO,
		"Roca2": Vector2.ZERO,
		"Roca3": Vector2.ZERO,
		"Tapon": true,
		"Tapon2": true
	}

	var save_result = ResourceSaver.save(fight_data, "user://fight_save.tres")

func apply_loaded_data() -> bool:
	if current_scene_path == "" or papyrus_position == Vector2.ZERO or items_positions.is_empty():
		return false

	# Intenta cambiar la escena
	var error = get_tree().change_scene_to_file(current_scene_path)
	if error != OK:
		return false

	await get_tree().process_frame  # Esperamos un frame para que la escena termine de cargarse
	await get_tree().process_frame  # Esperamos otro por si acaso

	if not ResourceLoader.exists(current_scene_path):
		return false
	else:
		print("✅ La escena existe en el disco, intentando cargarla...")

	# Verificamos si hay escena cargada
	var current_scene = get_tree().current_scene
	if not current_scene:
		return false

	# Aplicar posiciones y estados a los nodos
	if current_scene.has_node("Papyrus"):
		current_scene.get_node("Papyrus").position = papyrus_position

	if current_scene.has_node("Items/Roca"):
		current_scene.get_node("Items/Roca").global_position = items_positions.get("Roca", Vector2.ZERO)

	if current_scene.has_node("Items/Roca2"):
		current_scene.get_node("Items/Roca2").global_position = items_positions.get("Roca2", Vector2.ZERO)

	if current_scene.has_node("Items/Roca3"):
		current_scene.get_node("Items/Roca3").global_position = items_positions.get("Roca3", Vector2.ZERO)

	if current_scene.has_node("Tapones/Tapon"):
		var tapon_1 = current_scene.get_node("Tapones/Tapon")
		var tapon1_state = items_positions.get("Tapon", true)
		if tapon1_state:
			tapon_1.call("activate")
		else:
			tapon_1.call("deactivate")

	if current_scene.has_node("Tapones/Tapon2"):
		var tapon_2 = current_scene.get_node("Tapones/Tapon2")
		var tapon2_state = items_positions.get("Tapon2", true)
		if tapon2_state:
			tapon_2.call("activate")
		else:
			tapon_2.call("deactivate")
	return true

# Proceso inicial para cargar los datos
func start_load_process():
	if load_from_file():
		cargar_dialogos_leidos()  # Cargar diálogos leídos
		apply_loaded_data()
