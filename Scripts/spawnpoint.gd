extends Area2D

@onready var menu_spawnpoint: CanvasLayer = $MenuSpawnpoint  
@onready var panel: Control = menu_spawnpoint.get_node("Panel") 
@onready var save_button: Button = menu_spawnpoint.get_node("Panel/Save")
@onready var return_button: Button = menu_spawnpoint.get_node("Panel/Return")
@onready var heart: AnimatedSprite2D = menu_spawnpoint.get_node("Panel/heart")
@onready var papyrus: CharacterBody2D = $"../../Papyrus"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var selected_button_index: int = 0  
var menu_activo: bool
signal menu_activado(menu_activo)

var is_player_nearby: bool = false
var menu_recien_abierto: bool = false  
var can_select_buttons: bool = true  

func _ready():
	if not is_in_group("spawnpoints"):
		add_to_group("spawnpoints")
		
	if menu_spawnpoint and panel:
		panel.visible = false 
		menu_activo = false 
	else:
		print("Error: MenuSpawnpoint o Panel no encontrado.")

func _process(_delta):
	if is_player_nearby and Input.is_action_just_pressed("interactuar") and not menu_activo and can_select_buttons:
		InputMap.action_erase_events("cerrar")
		menu_activo = true
		GameState.cinematic_active = true  # Bloquear el menú de pausa
		emit_signal("menu_activado", menu_activo)
		panel.visible = true
		menu_recien_abierto = true  

	if panel.visible == true:
		panel.position = get_viewport().size / 2
		update_heart_position()

		if not menu_recien_abierto:
			handle_selection()

	if menu_recien_abierto:
		menu_recien_abierto = false 

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Papyrus":
		is_player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Papyrus":
		is_player_nearby = false
		if panel:
			panel.visible = false

func handle_selection():
	if not can_select_buttons:
		return  

	if Input.is_action_just_pressed("izq"):
		selected_button_index = 0
		update_heart_position()
	elif Input.is_action_just_pressed("der"):
		selected_button_index = 1
		update_heart_position()

	update_button_text_color()
	
	if Input.is_action_just_pressed("interactuar"):
		if selected_button_index == 0:
			can_select_buttons = false
			save_position()
			save_button.text = "Guardado!"
			audio_stream_player_2d.play()
			await get_tree().create_timer(2.0).timeout
			save_button.text = "Guardar"
			panel.visible = false
			menu_activo = false
			can_select_buttons = true 
			emit_signal("menu_activado", menu_activo)
			GameState.cinematic_active = false  # Bloquear el menú de pausa
			var cerrar_event = InputEventKey.new()
			cerrar_event.physical_keycode = Key.KEY_X  
			InputMap.action_add_event("cerrar", cerrar_event)
		elif selected_button_index == 1 and can_select_buttons:
			panel.visible = false
			menu_activo = false
			emit_signal("menu_activado", menu_activo)
			GameState.cinematic_active = false  # Bloquear el menú de pausa
			var cerrar_event = InputEventKey.new()
			cerrar_event.physical_keycode = Key.KEY_X  
			InputMap.action_add_event("cerrar", cerrar_event)

func save_position():
	if is_player_nearby:
		var current_scene_name = get_tree().current_scene.name
		GameState.save_checkpoint(current_scene_name, papyrus.position)
		papyrus.heal(680)
		GameState.save_game()  # Guardar los cambios


func update_heart_position():
	if save_button and return_button:
		var button_position = save_button.position if selected_button_index == 0 else return_button.position
		heart.position = button_position - Vector2(-30, -30)
	else:
		print("Error: Los botones no están asignados correctamente.")

func update_button_text_color():
	if selected_button_index == 0:
		save_button.modulate = Color(1, 1, 0)  
		var save_style = save_button.get_theme_stylebox("normal")
		if save_style and save_style is StyleBoxFlat:
			save_style.border_color = Color(1, 1, 0)  # Amarillo
		
		return_button.modulate = Color(1, 1, 1)  
		var return_style = return_button.get_theme_stylebox("normal")
		if return_style and return_style is StyleBoxFlat:
			return_style.border_color = Color(1, 1, 1)  # Blanco

	elif selected_button_index == 1:
		save_button.modulate = Color(1, 1, 1)  
		var save_style = save_button.get_theme_stylebox("normal")
		if save_style and save_style is StyleBoxFlat:
			save_style.border_color = Color(1, 1, 1)  # Blanco

		return_button.modulate = Color(1, 1, 0)
		var return_style = return_button.get_theme_stylebox("normal")
		if return_style and return_style is StyleBoxFlat:
			return_style.border_color = Color(1, 1, 0)  # Amarillo
