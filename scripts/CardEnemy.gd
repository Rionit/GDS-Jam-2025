extends Hittable

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var cooldown := 1.0
var is_cooling_down := false

func _process(delta: float) -> void:
	if velocity == Vector2.ZERO and !is_cooling_down:
		get_tree().create_timer(cooldown).timeout.connect(throw)
		is_cooling_down = true
	
	move_and_slide()

func throw():
	animation_player.play("rotate")
	var dir_to_player = (Player.global_position - global_position).normalized()
	velocity = dir_to_player * 600.0
	print("Velocity: " + str(velocity))
	is_cooling_down = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	velocity = Vector2.ZERO
	animation_player.pause()
	
