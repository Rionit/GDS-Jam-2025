extends Node
func _ready() -> void:
	AudioManager.fade_out_music()
	AudioManager.play_music(load("res://sound/turkish_lvl/hallway_music.wav"))
	AudioManager.fade_in_music()


func _on_area_2d_body_entered(body: Node2D) -> void:
	SceneManager.next_level()
