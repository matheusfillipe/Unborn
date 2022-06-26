extends Node

var Bubble = load("res://scenes/TextBubble.tscn")
var PauseMenu = load("res://scenes/PauseMenu.tscn")
var bubble = Bubble.instance()


const mobile_font_multiplier = 1.5

var music_player = AudioStreamPlayer.new()
var music_player_pos = 0.0
var fade = Tween.new()
var music_muted = false
var came_from_menu = true
var world_complexity = 0

var last_level_for_mode = {}
var current_scene_path = ""
var checkpoint = null
var pausemenu

var has_timer_started = false
var start_time = OS.get_unix_time()
var current_music = null

# TODO have a proper state management including this and checkpoints
var spirit_counter = {}
var has_left_safe_area = false

var is_mobile = false
var mobile_font_resized = {}


func start_timer():
	if not has_timer_started:
		start_time = OS.get_unix_time()
		has_timer_started = true

func get_game_time() -> int:
	return OS.get_unix_time() - start_time


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
	demon_hurt,
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
	preload("res://assets/SFX/DemonHurt.wav"),
	preload("res://assets/SFX/playerHurt.wav"),
]

enum Music {
	intro,
	entrance,
	welcome,
	heaven,
	hell,
	end,
	}
# and music
var music_list = [
	preload("res://assets/Music/Intro.mp3"),
	preload("res://assets/Music/Entrance.mp3"),
	preload("res://assets/Music/Welcome.mp3"),
	preload("res://assets/Music/Heaven.mp3"),
	preload("res://assets/Music/Hell.mp3"),
	preload("res://assets/Music/End.mp3"),
]


func _ready():
	match OS.get_name():
		"Android", "BlackBerry", "iOS":
			is_mobile = true
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

func _unhandled_input(event):
	if event.is_action_pressed("pause") and get_node("/root/main") != null:
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		unpause()
	else:
		pause()

func pause():
	get_tree().paused = true
	play(SFX.popup)
	music_player_pos = music_player.get_playback_position()
	music_player.stop()
	pausemenu = PauseMenu.instance()

	# Pause shaders
	Engine.time_scale = 0
	# TODO make fadeinHACK part of the player instead of huge thing
	get_node("/root/main/Control").add_child(pausemenu)
	get_node("/root/main/FadeInHack").modulate = Color(1, 1, 1, 0.5)
	get_node("/root/main/FadeInHack").visible = true

func unpause():
	get_tree().paused = false
	Engine.time_scale = 1
	music_player.play(music_player_pos)
	get_node("/root/main/FadeInHack").modulate = Color(1, 1, 1, 1)
	get_node("/root/main/FadeInHack").visible = false
	if is_instance_valid(pausemenu):
		pausemenu.queue_free()


# Safe disconnect
func sdisconnect(node: Node, _signal: String, target: Object, method: String):
	if node.is_connected(_signal, target, method):
		node.disconnect(_signal, target, method)

# Safe bind
func sconnect(node: Node, _signal: String, target: Object, method: String):
	if not node.is_connected(_signal, target, method):
		return node.connect(_signal, target, method)


# TODO this is no equiprobabilistic
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
	current_music = m
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
	current_music = m
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


# Remove all children of a node
static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

static func get_children_with_type(node, type):
	var matches = []
	for N in node.get_children():
		if N is type:
			matches.append(N)
		if N.get_child_count() > 0:
			matches += get_children_with_type(N, type)
	return matches

# Based on average reading time
const WPM = 200
static func read_time(t: String):
# warning-ignore:integer_division
	return len(t.split(" ")) * 60 / WPM

func multiply_node_font(node: Node):
	var r_name = str(node.get_font('font'))
	if r_name in mobile_font_resized:
		return
	node.get_font('font').size *= Global.mobile_font_multiplier
	mobile_font_resized[r_name] = true

# If mobile increase font size of children label nodes
func multiply_font_size(parent: Node):
	if not Global.is_mobile:
		return

	for label in Global.get_children_with_type(parent, Label):
		multiply_node_font(label)

	for btn in Global.get_children_with_type(parent, Button):
		multiply_node_font(btn)
