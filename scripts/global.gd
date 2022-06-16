extends Node

var Bubble = load("res://scenes/TextBubble.tscn")
var bubble = Bubble.instance()

var music_player = AudioStreamPlayer.new()
var fade = Tween.new()
var music_muted = false
var came_from_menu = true

var last_level_for_mode = {}
var current_scene_path = ""


# Let's preload the audio effects
enum SFX {
	boom,
	gatebreak,
	pop,
	colide,
	popup,
	tick,
	death,
	angel_hurt,
	player_hurt,
	}

var sfx_list = [
	preload("res://assets/SFX/Boom.wav"),
	preload("res://assets/SFX/gateBreak.wav"),
	preload("res://assets/SFX/pop.wav"),
	preload("res://assets/SFX/colide.wav"),
	preload("res://assets/SFX/popup.wav"),
	preload("res://assets/SFX/tick.wav"),
	preload("res://assets/SFX/death.wav"),
	preload("res://assets/SFX/AngelHurt.wav"),
	preload("res://assets/SFX/playerHurt.wav"),
]

enum Music {
	intro,
	entrance,
	welcome,
	heaven,
	hell
	}
# and music
var music_list = [
	preload("res://assets/Music/Intro.mp3"),
	preload("res://assets/Music/Entrance.mp3"),
	preload("res://assets/Music/Welcome.mp3"),
	preload("res://assets/Music/Heaven.mp3"),
	preload("res://assets/Music/Hell.mp3"),
]


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(music_player)
	add_child(fade)


func popup(message, time):
	if is_instance_valid(bubble):
		bubble.hide()
	play(SFX.popup)
	bubble = Bubble.instance()
	bubble.popup(message, time)


func show_text(message, time):
	if is_instance_valid(bubble):
		bubble.hide()
	bubble = Bubble.instance()
	bubble.show(message, time)
	return bubble

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused

		# Pause shaders
		if get_tree().paused:
			play(SFX.popup)
			music_player.playing = false
			Engine.time_scale = 0
			bubble = Bubble.instance()
			bubble.show("PAUSED", true)
		else:
			Engine.time_scale = 1
			bubble.hide()
			music_player.playing = true


# Safe disconnect
func sdisconnect(node: Node, _signal: String, target: Object, method: String):
	if node.is_connected(_signal, target, method):
		node.disconnect(_signal, target, method)

func random_vec2() -> Vector2:
   var new_dir: = Vector2()
   randomize()
   new_dir.x = rand_range(-1, 1)
   randomize()
   new_dir.y = rand_range(-1, 1)
   return new_dir.normalized()

func sum(arr: Array) -> float:
	var r = 0
	for a in arr:
		r += a
	return r

func is_from_menu():
	var before = came_from_menu
	came_from_menu = false
	return before

func menu_button():
	music_player.playing = false
	music_player.stop()
	play(0)

func play_music(m):
	if music_muted:
		return

	if music_player.playing:
		# fade out 1 second
		fade.interpolate_property(music_player, "volume_db", 0, -80, 1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		fade.start()
		yield(fade, "tween_all_completed")
		music_player.stop()
		music_player.volume_db = 0

	music_player.stream = music_list[m]
	music_player.play()

func play_music_once(m):
	if music_muted:
		return
	play_music(m)
	if not music_player.is_connected("finished", self, "stop_music_player"):
		music_player.connect("finished", self, "stop_music_player")

func stop_music_player():
	if music_player.is_connected("finished", self, "stop_music_player"):
		music_player.disconnect("finished", self, "stop_music_player")
	music_player.stop()

# Play audio effect
func play(m):
	var streamplayer = AudioStreamPlayer.new()
	streamplayer.connect("finished", streamplayer, "queue_free")
	add_child(streamplayer)
	streamplayer.stream = sfx_list[m]
	streamplayer.play()

# Play positioned audio effect
func play2d(m, pos: Vector2):
	var streamplayer = AudioStreamPlayer2D.new()
	streamplayer.global_position = pos
	streamplayer.connect("finished", streamplayer, "queue_free")
	add_child(streamplayer)
	streamplayer.stream = sfx_list[m]
	streamplayer.play()
