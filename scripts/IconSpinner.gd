extends Control
class_name IconSpinner

@onready var icon_1: Icon = $Icon1
@onready var icon_2: Icon = $Icon2
@onready var icon_3: Icon = $Icon3

@onready var rich_text_label: RichTextLabel = $"../RichTextLabel"

 ## vertical offset between the three icons
@export var offset := 30
@export var spin_speed := 2000.0
## How many full wraps before stopping, has to be 3,6,9,12,...
@export var cycles := 9    

var spinning := false
var wraps_done := 0
var icon_height := 0
var trans_type := Tween.TRANS_SPRING
var bounce_time := 1
var icons : Array[Icon]
var text_position : Vector2

func _ready() -> void:
	icon_height = icon_1.size.y + offset

	icons.append(icon_1)
	icons.append(icon_2)
	icons.append(icon_3)

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

	for icon in icons:
		_move_and_wrap(icon, delta)

	# Stop when enough wraps have completed
	if wraps_done >= cycles:
		_align_and_stop()

## Moves [param icon] down and wraps if threshold crossed
func _move_and_wrap(icon: Icon, delta: float) -> void:
	icon.position.y += spin_speed * delta

	# If it crossed below bottom threshold, wrap to top
	if icon.position.y >= icon_height:
		icon.position.y = -icon_height*2
		icon.randomize_icon()
		wraps_done += 1

## Transition back to default positions with "bounce"
func _align_and_stop():
	var final_perk = PerkMachine.get_final_perk()
	
	icon_2.change_icon(final_perk)
	rich_text_label.text = final_perk.format_text()
	rich_text_label.modulate.a = 0.0
	text_position = rich_text_label.position
	
	spinning = false

	var tween = create_tween()
	# idk how to make it bounce more
	tween.set_trans(trans_type).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(icon_1, "position:y", -icon_height, bounce_time)
	tween.parallel().tween_property(icon_2, "position:y", 0, bounce_time)
	tween.parallel().tween_property(icon_3, "position:y", icon_height, bounce_time)
	
	# THIS HUNDRED MIGHT NEED CHANGING IDK xd
	tween.tween_property(rich_text_label, "position:y", 100, 0.0)
	tween.tween_property(rich_text_label, "position:y", text_position.y, bounce_time / 2.0).set_delay(0.3)
	tween.parallel().tween_property(rich_text_label, "modulate:a", 1.0, bounce_time / 2.0).set_delay(0.3)
