extends Control

signal handle_pulled

const HANDLE_1 = preload("uid://cib7xfwegksj4")
const HANDLE_2 = preload("uid://c04vfkfncogw5")
const HANDLE_3 = preload("uid://bfuxax0xjhtlr")
const HANDLE_4 = preload("uid://chgmlwbtys6b2")

@onready var handle: TextureRect = $Handle

var mouse_over := false
var mouse_down := false
var mouse_start_position: Vector2
var handles : Array[Texture] = [HANDLE_1, HANDLE_2, HANDLE_3, HANDLE_4]
var current_handle := 0

## How far the user must drag down to reach the next texture
var step_distance := 40.0

func _ready() -> void:
	handle_pulled.connect(PerkMachine.spin_machine)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and mouse_over:
		mouse_down = true
		mouse_start_position = get_global_mouse_position()

	if event.is_action_released("shoot"):
		mouse_down = false
		for i in range(current_handle):
			handle.texture = handles[current_handle - i - 1]
			await get_tree().create_timer(0.2).timeout

func _process(delta: float) -> void:
	if mouse_down:
		var current_pos := get_global_mouse_position()
		var drag_amount := current_pos.y - mouse_start_position.y
		
		if drag_amount <= 0:
			handle.texture = HANDLE_1
			current_handle = 0
		elif drag_amount < step_distance:
			handle.texture = HANDLE_1
			current_handle = 0
		elif drag_amount < step_distance * 2:
			handle.texture = HANDLE_2
			current_handle = 1
		elif drag_amount < step_distance * 3:
			handle.texture = HANDLE_3
			current_handle = 2
		else:
			handle.texture = HANDLE_4
			current_handle = 3
			handle_pulled.emit()
		
func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
