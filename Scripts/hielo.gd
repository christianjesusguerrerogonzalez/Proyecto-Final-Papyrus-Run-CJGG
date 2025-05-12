extends Area2D

@export var deslizar_factor: float = 0.8

func _ready():
	
	disconnect("body_entered", Callable(self,"_on_body_entered"))
	disconnect("body_exited", Callable(self, "_on_body_exited"))

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body is CharacterBody2D and body.name == "Papyrus":
		body.start_sliding(deslizar_factor)

func _on_body_exited(body):
	if body is CharacterBody2D and body.name == "Papyrus":
		body.stop_sliding()
