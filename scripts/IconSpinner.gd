extends Control
class_name IconSpinner

@onready var icon_1: Icon = $Icon1
@onready var icon_2: Icon = $Icon2
@onready var icon_3: Icon = $Icon3

@export var rich_text_label: RichTextLabel

@export var offset := 15
@export var spin_speed := 2000.0
@export var cycles := 9    

var spinning := false
var wraps_done := 0
var icon_height := 0
var icons : Array[Icon]
var text_position : Vector2
var ease_progress := 0.0
var ease_duration := 0.4

func _ready() -> void:
	icon_height = icon_1.size.y + offset

	icons = [icon_1, icon_2, icon_3]

	icon_1.position.y = -icon_height
	icon_2.position.y = 0
	icon_3.position.y = icon_height
	
	rich_text_label.modulate.a = 0.0

func spin():
	if spinning:
		return
	spinning = true
	wraps_done = 0
	ease_progress = 0.0

func _process(delta: float) -> void:
	if not spinning:
		return
	
	if ease_progress < 1.0:
		ease_progress = min(ease_progress + delta / ease_duration, 1.0)
	var ease_factor := ease_progress * ease_progress

	for icon in icons:
		_move_and_wrap(icon, delta, ease_factor)

	if wraps_done >= cycles:
		_align_and_stop()

func _move_and_wrap(icon: Icon, delta: float, ease_factor: float) -> void:
	icon.position.y += spin_speed * delta * ease_factor

	if icon.position.y >= icon_height + 10:
		icon.position.y = -icon_height * 2
		icon.randomize_icon()
		wraps_done += 1

func _align_and_stop():
	var final_perk = PerkMachine.get_final_perk()
	icon_2.change_icon(final_perk)
	rich_text_label.text = final_perk.format_text()
	rich_text_label.modulate.a = 0.0
	text_position = rich_text_label.position

	spinning = false

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(icon_1, "position:y", -icon_height, 0.5)
	tween.parallel().tween_property(icon_2, "position:y", 0, 0.5)
	tween.parallel().tween_property(icon_3, "position:y", icon_height, 0.5)

	tween.tween_property(rich_text_label, "position:y", -20, 0.01)
	tween.tween_property(rich_text_label, "position:y", 20, 0.5).set_delay(0.3)
	tween.parallel().tween_property(rich_text_label, "modulate:a", 1.0, 0.5).set_delay(0.3)
