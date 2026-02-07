class_name AttackState
extends PlayerState
@onready var player_animations: PlayerAnimation = %PlayerAnimations

const HITBOX_OFFSET := 16.0
const HITBOX_LIFETIME := 0.15
var hitbox

func enter(_prev):
	player.consume_attack()
	player.velocity = Vector2.ZERO
	
	var resolved = player._resolve_direction(player.attack_direction)
	var animation = player_animations.animations[resolved][StateEnum.Value.ATTACK]
		
	player.sprite.stop()
	player.sprite.play(animation)
	player.sprite.animation_finished.connect(_on_finished, CONNECT_ONE_SHOT)
	
	_spawn_attack_hitbox(player.attack_direction)
	
func _on_finished():
	var next := (
		StateEnum.Value.RUN
		if player.wants_sprint
		else StateEnum.Value.IDLE
	)

	player.fsm.change_state(next)

func _spawn_attack_hitbox(direction: Vector2) -> void:
	# Spawn hitbox
	hitbox = preload("res://scenes/hitbox.tscn").instantiate()
	
	hitbox.source = player
	hitbox.global_position = player.global_position + direction * HITBOX_OFFSET

	get_tree().current_scene.add_child(hitbox)
	
	# Remove after a short time
	await get_tree().create_timer(HITBOX_LIFETIME).timeout
	hitbox.queue_free()

func _destroy_hitbox():
	if hitbox:
		hitbox.queue_free()
		hitbox = null
