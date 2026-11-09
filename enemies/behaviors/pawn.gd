extends CharacterBody2D

@export var speed : float = 2
@onready var pawn_sprite : AnimatedSprite2D = $AnimatedSprite2D

var input_vector : Vector2 = Vector2(0,0)


func _physics_process(delta):
	var player_position =GameManager.position_player
	var difference = player_position - position
	input_vector = difference.normalized()
	velocity = input_vector * speed * 100
	if input_vector.x >0:
		pawn_sprite.flip_h = false
	elif input_vector.x < 0:
		pawn_sprite.flip_h = true

	move_and_slide()
