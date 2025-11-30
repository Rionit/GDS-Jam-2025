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
var step_distance := 100.0

func _ready() -> void:
	handle_pulled.connect(PerkMachine.spin_machine)

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("attack") and mouse_over:
		#animate_handle()
	if event.is_action_pressed("attack"):
		animate_handle()

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false

func animate_handle():
	for i in range(handles.size()):
		handle.texture = handles[i]
		await get_tree().create_timer(0.1).timeout
	
	for i in range(handles.size()):
		handle.texture = handles[handles.size()-i-1]
		await get_tree().create_timer(0.1).timeout
	
	
