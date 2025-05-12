extends Node
@onready var papyrus: CharacterBody2D = $"../Papyrus"
var cinematic_active: bool = false
var last_checkpoint_scene: String = ""
var last_checkpoint_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if has_checkpoint():
		var result = load("user://save_test.tres")
		print("Cargando resultado del checkpoint:", result)
	else:
		print("No hay checkpoint guardado")

func save_checkpoint(scene_name: String, position: Vector2):
	last_checkpoint_scene = "res://Escenas/" + scene_name + ".tscn"
	last_checkpoint_position = position
	print("Guardando checkpoint en la escena:", last_checkpoint_scene, "Posición:", last_checkpoint_position)
	save_game()

func save_game():
	if last_checkpoint_scene != "" and last_checkpoint_position != Vector2.ZERO:
		var temp = CheckpointData.new()
		temp.scene_name = last_checkpoint_scene
		temp.checkpoint_position = last_checkpoint_position
		ResourceSaver.save(temp, "user://save_test.tres")
		print("Juego guardado correctamente.")
	else:
		print("Error: Datos incompletos para guardar el juego.")

func has_checkpoint():
	return FileAccess.file_exists("user://save_test.tres")

func load(path: String) -> bool:
	if FileAccess.file_exists(path):
		var resource = ResourceLoader.load(path)
		if resource:
			last_checkpoint_scene = resource.scene_name
			last_checkpoint_position = resource.checkpoint_position
			if last_checkpoint_scene != "" and last_checkpoint_position != Vector2.ZERO:
				print("Inicio gamestate para ruinas: ",Time.get_ticks_msec())
				get_tree().change_scene_to_file(last_checkpoint_scene)
				print("Fin gamestate para ruinas: ",Time.get_ticks_msec())
				await get_tree().process_frame
				await get_tree().process_frame

				var new_scene = get_tree().current_scene
				if new_scene.has_node("Papyrus"):
					papyrus = new_scene.get_node("Papyrus")
					papyrus.position = last_checkpoint_position
				else:
					print("Error: No se pudo encontrar el nodo Papyrus en la escena.")
					return false
			else:
				print("Datos del checkpoint no válidos.")
				return false
		else:
			print("No se pudo cargar el recurso.")
			return false
	return true




func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
