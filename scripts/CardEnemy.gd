extends Hittable

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export
var cooldown := 3.0
var is_cooling_down := false

@export
var health = 30

@export
var damage_anim_player : AnimationPlayer

func _ready():
	super()
	on_death.connect(Player.get_money)
	$PhysicsHitbox.body_entered.connect(_on_hitbox_body_entered)
	
func _process(delta: float) -> void:
	if !isDying:
		if velocity == Vector2.ZERO and !is_cooling_down:
			get_tree().create_timer(cooldown).timeout.connect(throw)
			is_cooling_down = true
	move_and_slide()

func throw():
	$Hitbox.collision_mask = 2
	animation_player.play("rotate")
	var dir_to_player = (Player.global_position - global_position).normalized()
	velocity = dir_to_player * 600.0
	print("Velocity: " + str(velocity))
	is_cooling_down = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("BODY ENTERED")
	velocity = Vector2.ZERO
	animation_player.pause()
	
func take_damage(damage : int, hitterPosition : Vector2):
	health -= damage
	if health <= 0:
		die()
	else:
		gain_invulnerability()
		damage_anim_player.play("DamageAnimation")
		
func die():
	isDying = true
	on_death.emit(self)
	$Hitbox.collision_mask = 0
	damage_anim_player.play("DieAnimation")
	await damage_anim_player.animation_finished
	
	queue_free()
	
