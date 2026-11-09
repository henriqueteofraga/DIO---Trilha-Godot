class_name Enemy # Criando um classe(Tipo) Enemy para usar em outros códigos
extends Node2D

@export var health : int = 1 #Setando a vida do inimigo
@export var death_prefab : PackedScene # Criando a variavel template de morte

#Drop de itens
@export_category("Drops")
@export var drop_chance : float = 0.1
@export var drop_list : Array[PackedScene]
@export var drop_rarity : Array[float]

var damage_digit_prefab : PackedScene

@onready var damage_digit_marker  = $DamageDigitMarker

func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")

#Função para o dar o dano
func damage(amount : int) -> void: #amount = quantidade de dano a ser subtraido
	health -= amount
	print("O inimigo recebeu ", amount, " de dano. Vida restante: ", health) #log do dano
	
	#visual de dano
	modulate = Color.RED #modulate para vermelho para o personagem piscar
	var tween= create_tween() #twwen anima a propriedade de forma suave
	# Define a curva de aceleração e a transição do tipo Quint para a animação do tween
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(tween.TRANS_QUINT)
	# o "self" é o próprio objeto, "modulate" é a propriedade, depois set a cor branca e quanto tempo leva
	tween.tween_property(self,"modulate",Color.WHITE,0.3)
	
# Criar DamageDigit
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	get_parent().add_child(damage_digit)
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	#get_parent().add_child(damage_digit)
	
#condicional de morte
	if health <=0:
		die()

#Função de morte
func die() -> void:
	#Animação de morte
	if death_prefab:
		var death_object = death_prefab.instantiate() #a animação da morte
		death_object.position = position #set a posição inicial da animação pra mesma que o objeto
		get_parent().add_child(death_object)#Adiciona a animação de morte na cena principal (no mesmo nível do pai) para ela aparecer na tela
	
	#Carne (Recupera vida)
	if randf() <= drop_chance:
		drop_item()
	GameManager.monster_defeated_count +=1
		
	queue_free()#exclui o objeto
		
func drop_item() -> void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position #set a posição inicial da animação pra mesma que o objeto
	get_parent().add_child(drop)#Adiciona a animação de morte na cena principal (no mesmo nível do pai) para ela aparecer na tela
	
func get_random_drop_item() -> PackedScene:
# Caso o enemy tenha só 1 drop
	if drop_list.size() ==1:
		return drop_list[0]
	
#Calcular chance maxima de drop caso tenha mais de um possível
	var max_chance : float = 0.0
	for drop_chance in drop_rarity:
		max_chance += drop_chance
	
	#jogar dado para decidir o drop
	var random_value = randf() * max_chance
	
	#Setar valor inicial /girar a roleta de drop
	var pick:float = 0.0
	for i in drop_list.size():
		var drop_item = drop_list[i]
		var drop_chance = drop_rarity[1] if i< drop_rarity.size() else 1
		if random_value <= drop_chance + pick:
			return drop_item
		pick += drop_chance
		
	return drop_list[0]
		
	
