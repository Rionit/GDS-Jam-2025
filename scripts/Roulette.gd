extends Node2D

@onready var markers: Node2D = $Markers
@onready var ball: Sprite2D = $Ball

var ball_positions : Array[Marker2D]

func _ready() -> void:
	for c in markers.get_children():
		ball_positions.append(c)
	
	animate(60)

func animate(steps: float): 
	var tween = create_tween()
	for i in range(steps):
		var dist = abs(i - (steps/2))
		tween.tween_property(ball, "global_position", ball_positions[i % ball_positions.size()].global_position, 0.2 * (dist/ 50.0))
