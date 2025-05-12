extends CanvasLayer

@onready var menu_panel: Panel = $Panel
@onready var save_button: Button = $Panel/Save
@onready var return_button: Button = $Panel/Return
@onready var heart: AnimatedSprite2D = $Panel/heart
@onready var label: Label = $Panel/Label
@onready var label_glitched: Label = $Panel/LabelGlitched
@onready var label_ultima_escena: Label = $Panel/LabelUltimaEscena

var last_scene: String = ""

func _ready():
	menu_panel.visible = true
	label.modulate = Color(1, 1, 1)  
	label_glitched.modulate = Color(1, 1, 1)  
	label_ultima_escena.text = get_tree().current_scene.name


func _process(_delta):
	# Generar números aleatorios para simular el texto glitcheado.
	var random_text = str(int(randf_range(100, 999))) + ":" + str(int(randf_range(10, 99)))
	label_glitched.text = random_text

func get_scene_name() -> String:
	var current_scene_path = get_tree().current_scene_owner
	return current_scene_path.get_file().get_basename()
