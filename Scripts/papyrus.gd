extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var progress_bar: ProgressBar = $ProgressBar
@export var speed: float = 100.0
@onready var areas_teletransporte: Node = $"../AreasTeletransporte"
@onready var label: Label = $Label
@onready var animation_player_bar: AnimationPlayer = $AnimationPlayerBar
@onready var animation_player_label: AnimationPlayer = $AnimationPlayerLabel
@onready var clover: Sprite2D = $Clover
@onready var chara: Sprite2D = $Chara
@onready var bone_scene = preload("res://Escenas/hueso.tscn")  # Pre-cargar la escena del hueso
@onready var cooldown_timer: Timer = $CooldownTimer

var ultima_direccion = Vector2.DOWN
var hitplayer = false
var is_dead = false
var max_health = 680
var current_health = max_health
var can_input_during_animation: bool = true
var is_moving = true  
var damage_amount: float = 0
var push_force: float = 100.0
var minpushforce: float = 10.0

var can_input: bool = true  
var is_sliding = false
var slide_factor = 1.0
var slide_velocity = Vector2.ZERO
var ice_patches = 0  # Contador de parches de hielo

var is_on_cooldown = false  # Para verificar si el cooldown está activo

func _ready():
	progress_bar.max_value = max_health
	progress_bar.value = current_health
	animation_player_bar.play("hpbarmoviendose")
	animation_player_label.play("hplabelmoviendose")

	# Configuración del cooldown
	cooldown_timer.wait_time = 1.0  # Ajusta el tiempo de espera entre lanzamientos de hueso
	cooldown_timer.one_shot = true  # Hace que el timer solo se ejecute una vez por cada cooldown
	cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_timeout"))
	cooldown_timer.start()
	await get_tree().process_frame

	for area_teletransporte in get_tree().get_nodes_in_group("tps"):
		area_teletransporte.connect("tele_activado", Callable(self, "_on_tele_activado"))
	
	for cartel in get_tree().get_nodes_in_group("carteles"):
		cartel.connect("menu_activado", Callable(self, "_on_menu_activado"))

	for dialogo in get_tree().get_nodes_in_group("dialogos"):
		dialogo.connect("dialogo_activado", Callable(self, "_on_dialogo_activado"))
		
	for interaccion in get_tree().get_nodes_in_group("interacciones"):
		interaccion.connect("interaccion_activada", Callable(self, "on_interaccion_activada"))
		
	for area in get_tree().get_nodes_in_group("areas_jefe"):
		area.connect("jefe_cinematic_activa", Callable(self, "_on_jefe_cinematic_activa"))
		print("Conectada señal jefe_cinematic_activa desde", area.name)

	for spawnpoint in get_tree().get_nodes_in_group("spawnpoints"):
		spawnpoint.connect("menu_activado", Callable(self, "_on_menu_activado"))

func _physics_process(_delta: float) -> void:
	if is_dead or not is_moving:
		return

	if is_sliding:
		velocity = slide_velocity
		move_and_slide()
		return

	var direction = Vector2.ZERO
	
	if !can_input:
		return
	
	if Input.is_action_pressed("arr"):
		direction.y -= 1
		clover.flip_h = false
		chara.flip_h = false
	if Input.is_action_pressed("aba"):
		direction.y += 1
		clover.flip_h = false
		chara.flip_h = false
	if Input.is_action_pressed("izq"):
		direction.x -= 1
		animated_sprite_2d.flip_h = true
		clover.flip_h = true
		chara.flip_h = false
	if Input.is_action_pressed("der"):
		direction.x += 1
		animated_sprite_2d.flip_h = false
		clover.flip_h = false
		chara.flip_h = true
	if direction.length() > 0:
		direction = direction.normalized()
		ultima_direccion = direction  

		if ultima_direccion.y < 0:  
			animated_sprite_2d.play("Andar_Arriba")
		elif ultima_direccion.y > 0:  
			animated_sprite_2d.play("Andar_Abajo")
		elif ultima_direccion.x != 0:  
			animated_sprite_2d.play("Andar_Derecha")
	else:
		if ultima_direccion == Vector2.UP:
			animated_sprite_2d.play("Quieto_Arriba")
		elif ultima_direccion == Vector2.DOWN:
			animated_sprite_2d.play("Quieto_Abajo")
		elif ultima_direccion.x != 0:
			animated_sprite_2d.play("Quieto_Derecha")

	velocity = direction * speed
	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var rb = collision.get_collider() as RigidBody2D
			var push_force_amount = push_force + minpushforce
			push_force_amount = clamp(push_force_amount, minpushforce, push_force)
			rb.apply_central_impulse(-collision.get_normal() * push_force_amount)

	# Lógica de lanzamiento del hueso con el espacio
	if Input.is_action_pressed("ui_accept") and not is_on_cooldown:  # Solo si el cooldown ha terminado
		spawn_bone()
		start_cooldown()

func spawn_bone():
	var bone = bone_scene.instantiate()  # Crear una instancia del hueso

	# Posicionar el hueso en la ubicación actual del personaje
	bone.position = position
	# Orientar el hueso según la dirección de Papyrus
	bone.rotation = ultima_direccion.angle()  # Esta línea es buena para la orientación

	bone.set_bone_direction(ultima_direccion)  # Asegúrate de que esta dirección esté correcta
	
	get_parent().add_child(bone)  # Añadir el hueso a la escena

func start_cooldown():
	is_on_cooldown = true
	cooldown_timer.start()

func _on_cooldown_timeout():
	is_on_cooldown = false

func _on_tele_activado(tele_activo: bool) -> void:
	if tele_activo:
		can_input = false  
		stop_moving()  
		if ultima_direccion.y < 0:
			animated_sprite_2d.play("Quieto_Arriba")
		elif ultima_direccion.y > 0:
			animated_sprite_2d.play("Quieto_Abajo")
		elif ultima_direccion.x < 0:
			animated_sprite_2d.play("Quieto_Arriba")  # Cambiado para coherencia
	else:
		can_input = true  
		resume_movement()  

func _on_menu_activado(menu_activo: bool) -> void:
	print("Función _on_menu_activado llamada con valor:", menu_activo)
	if menu_activo:
		can_input = false
		stop_moving()
	else:
		can_input = true
		resume_movement()



func _on_dialogo_activado(dialogo_activo: bool) -> void:
	if dialogo_activo:
		can_input = false
		stop_moving()
	else:
		can_input = true
		resume_movement()

func on_interaccion_activada(interaccion_activada: bool) -> void:
	if interaccion_activada:
		can_input = false
		stop_moving()
	else:
		can_input = true
		resume_movement()
		
		
func stop_moving():
	is_moving = false

func resume_movement():
	is_moving = true

func _on_damage_taken():
	take_damage()

func take_damage():
	current_health -= damage_amount
	progress_bar.value = current_health

	if current_health < 0:
		current_health = 0
		update_hp_label()
	if current_health == 0:
		is_dead = true
		speed = 0
		animated_sprite_2d.play("muerte")
		
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://Escenas/game_over.tscn")
	update_hp_label()

func heal(amount: float):
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	progress_bar.value = current_health
	update_hp_label()

func update_hp_label():
	label.text = "HP: %d/%d" % [current_health, max_health]

func start_sliding(factor: float):
	ice_patches += 1  
	if not is_sliding:
		is_sliding = true
		slide_factor = factor
		slide_velocity = velocity * factor  
		can_input = false  

func stop_sliding():
	ice_patches -= 1 
	if ice_patches <= 0: 
		is_sliding = false
		can_input = true

func _on_jefe_cinematic_activa(tiempo: float):
	can_input = false
	stop_moving()
	await get_tree().create_timer(tiempo).timeout
	can_input = true
	resume_movement()

func is_papyrus_moving() -> bool:
	return velocity.length() > 0
