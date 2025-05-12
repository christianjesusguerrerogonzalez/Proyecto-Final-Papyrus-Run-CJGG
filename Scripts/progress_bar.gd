extends ProgressBar

var maxvalor:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maxvalor= 680;

func DisminuirVida(damage):
	value-=damage
