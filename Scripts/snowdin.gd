extends Node2D

@export var antorcha_scene: PackedScene
@export var arbol_scene: PackedScene
@export var bola_nieve_scene: PackedScene

const POSICIONES = [
	Vector2(2384, 1517), Vector2(2475, 1517), Vector2(2566, 1517),
	Vector2(2657, 1517), Vector2(2748, 1517), Vector2(2839, 1517),
	Vector2(2930, 1517), Vector2(3021, 1517), Vector2(3112, 1517)
]

var cantidades = {"antorcha": 0, "arbol": 0, "bola_nieve": 0}

func _ready():
	await get_tree().process_frame  # Espera un frame antes de instanciar

	var posiciones_restantes = POSICIONES.duplicate()  # Duplica la lista original para evitar modificarla
	var escenas = {
		"antorcha": antorcha_scene,
		"arbol": arbol_scene,
		"bola_nieve": bola_nieve_scene
	}
	
	for i in range(9):
		await get_tree().process_frame  # Espera un frame antes de instanciar
		var tipo = ["antorcha", "arbol", "bola_nieve"].pick_random()
		var packed_scene = escenas[tipo]
		if packed_scene is PackedScene:
			var instancia = packed_scene.instantiate()
			
			# Asegúrate de obtener una posición válida
			if posiciones_restantes.size() > 0:
				var posicion = posiciones_restantes.pop_front()  # Extrae una posición válida
				add_child(instancia)
				
				if instancia is Node2D:
					instancia.position = posicion
					print("Posición asignada a: ", tipo, " en ", posicion)
				elif instancia.has_node("root"):  # Busca un nodo hijo llamado 'root'
					var nodo_hijo = instancia.get_node("root")
					if nodo_hijo is Node2D:
						nodo_hijo.position = posicion
						print("Posición asignada al nodo hijo: ", tipo, " en ", posicion)
					else:
						print("Advertencia: Nodo hijo no tiene 'position'.")
				else:
					print("Advertencia: Nodo raíz no tiene 'position'. Tipo: ", typeof(instancia))

				cantidades[tipo] += 1
			else:
				print("Error: No quedan posiciones disponibles. Salta esta iteración.")
		else:
			print("Error: ", tipo, " no es un PackedScene.")
