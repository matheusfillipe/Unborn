extends Node

var Bubble = load("res://scenes/TextBubble.tscn")
var bubble = Bubble.instance()

var music_player = AudioStreamPlayer.new()
var music_muted = false
var came_from_menu = true

var last_level_for_mode = {}
var current_scene_path = ""


# Let's preload the audio effects
enum SFX {
	boom,
	}
var sfx_list = [
    preload("res://assets/SFX/Boom.wav"),
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


func popup(message, time):
	if is_instance_valid(bubble):
		bubble.hide()
	bubble = Bubble.instance()
	bubble.popup(message, time)


func show_text(message, time):
	if is_instance_valid(bubble):
		bubble.hide()
	bubble = Bubble.instance()
	bubble.show_text(message, time)
	return bubble

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused

		# Pause shaders
		if get_tree().paused:
			Engine.time_scale = 0
			bubble = Bubble.instance()
			bubble.show("PAUSED")
		else:
			Engine.time_scale = 1
			bubble.hide()

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
	music_player.stop()
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
