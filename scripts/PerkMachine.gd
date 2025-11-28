extends Control

@onready var icon_spinner_1: IconSpinner = %IconSpinner
@onready var icon_spinner_2: IconSpinner = %IconSpinner2
@onready var icon_spinner_3: IconSpinner = %IconSpinner3


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		
		icon_spinner_1.cycles = 9
		icon_spinner_1.spin()
		icon_spinner_2.cycles = 12
		icon_spinner_2.spin()
		icon_spinner_3.cycles = 15
		icon_spinner_3.spin()
