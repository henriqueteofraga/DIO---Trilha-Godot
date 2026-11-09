class_name Player
extends CharacterBody2D

#							Variaveis OnReady
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite
@onready var sword_hitbox : Area2D = $SwordHitBox #hitbox da arma
@onready var hitbox_area : Area2D = $HitboxArea #hitbox do player
@onready var health_progress_bar : ProgressBar = $HealthProgressBar # Barra de vida do player

signal  meat_collected(value : int)
# 							Variaveis Exportaveis
@export_category("Movimento")
@export var speed : float = 3

@export_category("Combate")
@export var sword_damage : int = 2 #dano da espada
@export_category("Magia")
@export var ritual_damage : int 
@export var ritual_interval : float = 30
@export var ritual_scene : PackedScene

@export_category("Player")
@export var health : int = 20 #Setando a vida do player
@export var max_health : int = 100 #Setando a vida do player
@export var death_prefab : PackedScene # Criando a variavel template de morte

#							Declaração de Variaveis utilitárias

var is_running : bool = false
var was_running : bool = false
var is_attacking : bool = false
var attack_cooldown : float = 0.0
var hitbox_cooldown : float = 0.0
var ritual_cooldown : float = 0.0
var input_vector : Vector2 = Vector2(0,0)

# Tipos de ataque
var attack_side = ["attack_side", "attack_side2"]
var attack_up = ["attack_up", "attack_up2"]
var attack_down = ["attack_down", "attack_down2"]


#						Usando funções basicas do GoDot

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value: int): 
		GameManager.meat_count+=1)
func _process(delta: float) -> void:
	GameManager.position_player = position #avisa a info da posição pro manager
	read_input()
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()

	play_animation_idle()
	if not is_attacking:
		rotate_sprite()

#Processar dano
	update_hitbox_detection(delta)
	
	update_ritual(delta)
	
	#Barra de vida do player
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
	
##############################################################################
func _physics_process(delta: float) -> void:
	#				Modificar a velocidade do personagem(fazendo ele se mover)
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity,0.05 )
	move_and_slide()

##################################################################################
#  					Criação de funções personalizadas

#Ler inputs
func read_input():
	#Obter a direção para onde irá se mover
	input_vector = Input.get_vector("move_left","move_right","move_up","move_down",0.15)
	
	#Apagar Deadzone
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0
		
		#Validar se estava correndo
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

#Função de atacar
func attack() -> void:
	if is_attacking: #quebra loop de ataque mto rapido
		return
	var variation = randi_range(0, 1)
	if Input.is_action_pressed("move_up"):
		animation_player.play(attack_up[variation])
	elif Input.is_action_pressed("move_down"):
		animation_player.play(attack_down[variation])
	else:
		animation_player.play(attack_side[variation])
	
	
	
	attack_cooldown = 0.6
	
	is_attacking = true

#Função de dar o dano efetivamente
func deal_damage_to_enemies() -> void:
	#pega o corpo de colisão e valida se a espada bateu
	var bodies = sword_hitbox.get_overlapping_bodies()
	#pega todos os corpos que estão na area da espada e criam o hit fisico
	for body in bodies:
		if body.is_in_group("enemies"): #se o corpo for do grupo "enemies" ele habilita a colisão
			var enemy : Enemy = body #cria o corpo do inimgo em questão
			var direction_to_enemy = (enemy.position - position).normalized() #valida se o inimigo ta na frente do player
			#Cria o vetor que valida se o ataque ta na direção do inimigo
			var attack_direction : Vector2
			#IF valida se o player ta virado pra esquerda, o else pra direita
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			#cria a varial que valida a posição do inimigo
			var dot_product = direction_to_enemy.dot(attack_direction)
			#If valida se o inimigo ta no range de alcance
			if dot_product > 0.3:#Caso true dá o dano no imimigo
				enemy.damage(sword_damage)

#Função do Cooldown do ataque
func update_attack_cooldown(delta:float) -> void:
		#Atualizar temporizador de ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <=0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func update_ritual(delta : float) -> void:
	#temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0 : return
	ritual_cooldown = ritual_interval
	
	#criar o ritual
	var ritual = ritual_scene.instantiate()
	ritual.ritual_damage = ritual_damage
	add_child(ritual)
	
#Configuração da animação Idle(parado) e runing(correndo)
func play_animation_idle() ->void:
	#Tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

#Rotacionando a Sprite do personagem conforme o input de andar para esquerda/direita
func rotate_sprite() -> void:
		if input_vector.x >0:
			sprite.flip_h = false
		elif input_vector.x < 0:
			sprite.flip_h = true
			

#Função para validar se o player tomou dano
func update_hitbox_detection(delta : float) -> void:
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	hitbox_cooldown = 0.6
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy : Enemy = body
			var damage_amount = 1
			damage(damage_amount)

#Função para receber o dano tomado
func damage(amount : int) -> void: #amount = quantidade de dano a ser subtraido
	if health <=0:return
	health -= amount
	print("O player recebeu ", amount, " de dano. Vida restante: ", health, "/", max_health) #log do dano
	
	#visual de dano
	modulate = Color.RED #modulate para vermelho para o personagem piscar
	var tween= create_tween() #twwen anima a propriedade de forma suave
	# Define a curva de aceleração e a transição do tipo Quint para a animação do tween
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(tween.TRANS_QUINT)
	# o "self" é o próprio objeto, "modulate" é a propriedade, depois set a cor branca e quanto tempo leva
	tween.tween_property(self,"modulate",Color.WHITE,0.3)
	
#condicional de morte
	if health <=0:
		die()

#Função de morte
func die() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate() #a animação da morte
		death_object.position = position #set a posição inicial da animação pra mesma que o objeto
		get_parent().add_child(death_object)#Adiciona a animação de morte na cena principal (no mesmo nível do pai) para ela aparecer na tela
	print("Player morreu!")
	queue_free()#exclui o objeto
	
#Recuperação de vida
func regen_life(amount_healed:int) -> int:
	health += amount_healed
	if health > max_health:
		health = max_health
	print("O player recuperou ", amount_healed, " de vida. Vida restante: ", health, "/", max_health) #log do dano
	return health

