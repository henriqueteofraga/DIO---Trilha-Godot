class_name GameOver_UI
extends CanvasLayer
@onready var time_label : Label = %TimeValueLabel
@onready var monster_label : Label = %MonsterValueLabel

@export var restart_delay : float = 5.0
var restart_cooldown : float

func _ready() -> void:
	time_label.text = GameManager.time_elapsed_string
	monster_label.text = str(GameManager.monster_defeated_count)
	restart_cooldown =restart_delay
	
func _process(delta) -> void:
	restart_cooldown -= delta
	if restart_cooldown < 0 :
		restart_game()
		
func restart_game() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()

