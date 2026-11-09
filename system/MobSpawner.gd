class_name MobSpawner
extends Node2D

@export var creatures : Array[PackedScene]
@export var mobs_per_minute : float = 60.0

@onready var path_follow_2d : PathFollow2D = %PathFollow2D
var cooldown : float = 0.0

func _process(delta : float):
	if GameManager.is_game_over:return
	#Temporizador(cooldown)
	cooldown -= delta
	if cooldown > 0: return
	
	#Frequencia: monstros por segundo
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	#Validando o local do mobspawner
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1001 # Esse comentario será grande:
	#Parara o Colission_mask funcionar, tem que marcar quais layer o colission
	#vai respeitar. O valawto segue a logica
	#0b = informa que os valores passados são em bits, 1 é true 0 é false
	#os valores são lidos de tras pra frente, no caso 0b1000 diz que as layers
	#1 até a 3 são false(ignoradas) e a 4 layer é true. Se fosse a sexta layer
	#por exemplo seria 0b100000. Se fosse a 10º layer seria 0b1000000000
	#Espero que o Henrique do futuro entenda
	var result : Array =  world_state.intersect_point(parameters, 1)
	if not result.is_empty(): return
	
	#instanciar uma criatura aleatoria
	var index = randi_range(0, creatures.size() - 1)
	var creatures_scene = creatures[index]
	var creature = creatures_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature)
	
	
	
func get_point() -> Vector2 :
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
