extends Sprite2D

func _ready() -> void:
	# Start invisible
	modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Move up 100px
	tween.tween_property(self, "position:y", position.y - 50, 1.0)

	# Fade in
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.6)

	# Fade out after reaching the top
	tween.tween_property(self, "modulate:a", 0.0, 0.5)

	# Free once tween finishes
	tween.finished.connect(queue_free)
