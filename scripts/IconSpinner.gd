extends Control
class_name IconSpinner

@onready var icon_1: TextureRect = $Icon1
@onready var icon_2: TextureRect = $Icon2
@onready var icon_3: TextureRect = $Icon3

 ## offset between the three icons
@export var offset := 30
@export var spin_speed := 2000.0
## How many full wraps before stopping, has to be 3,6,9,12,...
@export var cycles := 9    

var spinning := false
var wraps_done := 0
var icon_height := 0
var trans_type := Tween.TRANS_SPRING
var bounce_time := 1

func _ready() -> void:
	icon_height = icon_1.size.y + offset

	icon_1.position.y = -icon_height
	icon_2.position.y = 0
	icon_3.position.y = icon_height

## Starts spinning [param cycles] amount of times
func spin():
	if spinning:
		return
	spinning = true
	wraps_done = 0

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#spin()

func _process(delta: float) -> void:
	if not spinning:
		return

	_move_and_wrap(icon_1, delta)
	_move_and_wrap(icon_2, delta)
	_move_and_wrap(icon_3, delta)

	# Stop when enough wraps have completed
	if wraps_done >= cycles:
		_align_and_stop()

## Moves icon down and wraps if threshold crossed
func _move_and_wrap(icon: TextureRect, delta: float) -> void:
	icon.position.y += spin_speed * delta

	# If it crossed below bottom threshold, wrap to top
	if icon.position.y >= icon_height:
		icon.position.y = -icon_height*2 - offset
		wraps_done += 1
		
		# TODO: Change icon sprite!!

## Transition back to default positions with "bounce"
func _align_and_stop():
	spinning = false

	var tween = create_tween()
	# idk how to make it bounce more
	tween.set_trans(trans_type).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(icon_1, "position:y", -icon_height, bounce_time)
	tween.parallel().tween_property(icon_2, "position:y", 0, bounce_time)
	tween.parallel().tween_property(icon_3, "position:y", icon_height, bounce_time)
