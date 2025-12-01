extends Node2D

@onready var sfx: AudioStreamPlayer = $SFX
@onready var music: AudioStreamPlayer = $Music

const AUDIO_SOURCE_SFX = preload("uid://hbvxtjxps7np")

func _ready() -> void:
	pass

func play_sfx(stream: AudioStream, volume: float = 1.0) -> void:
	var src = AUDIO_SOURCE_SFX.instantiate()
	add_child(src)
	src.stream = stream
	src.volume_db = volume
	src.finished.connect(func(): src.queue_free())
	print("playing sound " + stream.resource_path)
	src.play()

func play_music(stream: AudioStream, volume: float = -80.0) -> void:
	music.stream = stream
	music.volume_db = volume
	print("playing msuic " + stream.resource_path)
	music.play()

func stop_music() -> void:
	music.stop()

func fade_in_music(duration: float = 1.0, target_db: float = 0.0):
	fade_music(target_db, Tween.EASE_IN, duration)
	
func fade_out_music(duration: float = 1.0, target_db: float = -80.0):
	fade_music(target_db, Tween.EASE_OUT, duration)

func fade_music(target_db: float, fade_ease: Tween.EaseType = Tween.EASE_IN_OUT, duration: float = 1.0) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(music, "volume_db", target_db, duration)
	await tween.finished

func is_music_playing() -> bool:
	return music.playing

func is_sfx_playing() -> bool:
	return sfx.playing
