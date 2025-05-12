extends Area2D
@export var damage_amount: float = 200 

func _on_body_entered(body):
	if body.name == "Papyrus":
		body.damage_amount = damage_amount 
		body.take_damage()  
