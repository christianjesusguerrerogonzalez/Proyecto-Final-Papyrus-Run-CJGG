extends Area2D

@export var enemy_scenes: Array[PackedScene]  # Array de escenas de enemigos
@export var encounter_probability: float = 0.1  # Probabilidad de que ocurra un encuentro (10%)
@onready var papyrus: CharacterBody2D = null  # Inicialmente null hasta asignar un valor válido
@onready var roca: RigidBody2D = $"../../Items/Roca"
@onready var roca_2: RigidBody2D = $"../../Items/Roca2"
@onready var roca_3: RigidBody2D = $"../../Items/Roca3"
@onready var tapon: Sprite2D = $"../../Tapones/Tapon"
@onready var tapon_2: Sprite2D = $"../../Tapones/Tapon2"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var cooldown_active: bool = true  # Variable única para manejar todos los estados de cooldown

# Tiempos de cooldown
const INITIAL_COOLDOWN_TIME: float = 10.0  # Tiempo inicial antes de habilitar encuentros
const ENCOUNTER_COOLDOWN_TIME: float = 4.0  # Tiempo de cooldown tras salir de una batalla

func _ready():
	# Configurar cooldown inicial
	var cooldown_timer = Timer.new()
	cooldown_timer.wait_time = INITIAL_COOLDOWN_TIME  # Cooldown inicial de 10 segundos
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))
	add_child(cooldown_timer)
	cooldown_timer.start()

	# Configurar temporizador para verificar encuentros
	var encounter_timer = Timer.new()
	encounter_timer.wait_time = 0.5  # Verificar cada 0.5 segundos
	encounter_timer.one_shot = false
	encounter_timer.connect("timeout", Callable(self, "_check_for_encounter"))
	add_child(encounter_timer)
	encounter_timer.start()

	# Conectar todos los nodos en el grupo "dialogos"
	for dialogo in get_tree().get_nodes_in_group("dialogos"):
		dialogo.connect("dialogo_activado", Callable(self, "_on_dialogo_activado"))

	connect("body_entered", Callable(self, "_on_body_entered"))

func _check_for_encounter() -> void:
	# Verificar si Papyrus está en movimiento y si el cooldown no está activo
	if papyrus and not cooldown_active and papyrus.is_papyrus_moving():
		var random_value = randf()  # Generar un número aleatorio
		if random_value < encounter_probability:
			trigger_encounter()

func _on_body_entered(body):
	if body is CharacterBody2D:
		papyrus = body  # Asignar a Papyrus el objeto que entra en el área

func trigger_encounter() -> void:
	if enemy_scenes.size() > 0 and papyrus:  # Comprobar si hay enemigos y si Papyrus no es null
		# Guardar posiciones de Papyrus, las rocas y los estados de los tapones antes de iniciar la batalla
		PositionSave.save_position_and_scene(
			"LasRuinas",  # Nombre de la escena actual
			papyrus.global_position,  # Posición de Papyrus
			roca.global_position,    # Posición de la primera roca
			roca_2.global_position,  # Posición de la segunda roca
			roca_3.global_position,  # Posición de la tercera roca
			tapon.is_active,       # Estado del primer tapón
			tapon_2.is_active        # Estado del segundo tapón
		)
		# Guardar todos los diálogos leídos en el área actual
		for dialogo in get_tree().get_nodes_in_group("dialogos"):
			if dialogo.dialog_id != "" and dialogo.dialogo_completado:
				PositionSave.marcar_dialogo_leido(dialogo.dialog_id)
		# Cambiar a la escena de batalla
		var chosen_enemy_scene = select_random_enemy_scene()
		get_tree().change_scene_to_packed(chosen_enemy_scene)
		# Activar cooldown tras la batalla
		cooldown_active = true
		var battle_cooldown_timer = Timer.new()
		battle_cooldown_timer.wait_time = ENCOUNTER_COOLDOWN_TIME
		battle_cooldown_timer.one_shot = true
		battle_cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))
		add_child(battle_cooldown_timer)
		battle_cooldown_timer.start()

func _on_cooldown_timeout():
	# Desactivar cooldown
	cooldown_active = false

func select_random_enemy_scene() -> PackedScene:
	# Si solo hay un enemigo, devolverlo directamente
	if enemy_scenes.size() == 1:
		return enemy_scenes[0]

	# Si hay más de un enemigo, distribuir probabilidades equitativas
	var probability = 1.0 / enemy_scenes.size()
	var random_value = randf()
	for index in range(enemy_scenes.size()):
		if random_value < probability * (index + 1):
			return enemy_scenes[index]  # Devuelve el PackedScene seleccionado
	return enemy_scenes[0]  # Por defecto al primer enemigo si algo falla

func _on_dialogo_activado(dialogo_activo: bool) -> void:
	# Pausar o reanudar los encuentros según el estado del diálogo
	cooldown_active = dialogo_activo
