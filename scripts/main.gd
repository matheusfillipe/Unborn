extends Node2D

# TODO
# Make the angel follow the player
# Make the angel pathfind
# Auto generation of scenery as player walks. Adding fences and disposing of them in a long radius. how to distrubute them? Repeat Preloaded pattern? Seed generation?

var Spirit = preload("res://scenes/Spirit.tscn")
var Demon = preload("res://scenes/Demon.tscn")
var Angel = preload("res://scenes/Angel.tscn")
var Bubble = preload("res://scenes/TextBubble.tscn")
var Explosion = preload("res://effects/Explosion.tscn")
var ShockWave = preload("res://effects/ShockWave.tscn")
var Fence = preload("res://scenes/Fence.tscn")

onready var player = $Player
onready var overlay = $FadeInHack
onready var tween = $Tween
onready var spirits = $Spirits
onready var enemies = $Enemies
onready var camera = $Camera2D
onready var safearea = $RemoveLater/SafeArea
onready var environment = $WorldEnvironment


var has_left_safe_area = false
var last_world_update = 0.0

export(float, 1, 10000) var spirit_spawn_radius = 1000.0
export(float, 0, 2) var spirit_spaw_density = 2
export(float, 1, 10000) var enemy_spawn_radius = 1000.0
export(float, 0, 2) var enemy_spawn_density = 2
export(int, 1, 100) var enemy_spawn_limit = 10

enum Scenery {
	safezone,
	hell,
	heaven
}

# Current scenery
var scenery = Scenery.safezone setget set_scenery

func _ready():
	# platform specific adjust
	match OS.get_name():
		"Android":
			environment.auto_exposure_min_luma = 0.08
		"BlackBerry":
			pass
		"10":
			pass
		"Flash":
			pass
		"Haiku":
			pass
		"iOS":
			pass
		"HTML5":
			pass
		"OSX":
			pass
		"Server":
			pass
		"Windows":
			pass
		"WinRT":
			pass
		"X11":
			pass

	Global.play_music_once(Global.Music.entrance)
	player.connect("size_changed", self, "adjust_zoom")
	player.connect("died", self, "player_died")
	compile_shaders()

	# Pause and create transition effect on the beginning
	overlay.visible = true
	yield(get_tree().create_timer(1, false), "timeout")
	overlay.visible = false

	yield(get_tree().create_timer(7, false), "timeout")
	if scenery == Scenery.safezone:
		Global.play_music(Global.Music.welcome)


# HACK Avoid hickup for when effects are used first time. godot 3.5 has something better for this
func compile_shaders():
	var explosion = Explosion.instance()
	explosion.global_position = Vector2(10000, 10000)
	add_child(explosion)

	var node = ShockWave.instance()
	node.global_position = Vector2(10000, 10000)
	add_child(node)


func adjust_zoom(size: float):
	var delay = 0.0
	if size == player.initial_size:
		delay = 2

	var zoom = 1.0 + size / player.initial_size / 10.0

	tween.interpolate_property(camera, "zoom",
		camera.zoom,
		Vector2.ONE * zoom,
		2,
		tween.TRANS_LINEAR,
		tween.EASE_IN_OUT,
		delay
	)
	tween.start()

# Nice metallica song btw
func fade_to_black(callback: String):
	overlay.modulate = Color(1, 1, 1, 0)
	overlay.visible = true
	tween.interpolate_property(overlay, "modulate",
		overlay.modulate,
		Color(1, 1, 1, 1),
		2,
		tween.TRANS_LINEAR,
		tween.EASE_IN_OUT
	)
	tween.connect("tween_all_completed", self, callback)
	tween.start()

func restart():
	Global.sdisconnect(tween, "tween_all_completed", self, "restart")
	get_tree().reload_current_scene()

func player_died(message):
	Global.play(Global.SFX.death)
	yield(get_tree().create_timer(2, false), "timeout")
	Global.popup(message, 3)
	yield(get_tree().create_timer(2, false), "timeout")
	restart()

# Spawn spirits randomly
func spawn_spirit():
	var color_chances = [
		0.5,  # WHITE
		0.0,  # BLACK
		0.0,  # BLUE
		0.05,  # GREEN
		0.3,  # YELLOW
		0.1,  # RED
	]

	randomize()
	var r = randf()
	var v = 0.0
	var i = 0
	for c in color_chances:
		v += c
		if r <= v:
			break
		i += 1

	if i >= len(color_chances):
		return

	var dir = Global.random_vec2()
	var spirit = Spirit.instance()

	spirit.start_color = i
	spirits.add_child(spirit)
	spirit.global_position = dir * spirit_spawn_radius + player.global_position
	spirit.velocity = - dir * rand_range(50, 500)
	spirit.noise_amplitude = rand_range(1, 10)
	spirit.noise_speed = rand_range(2, 20)
	spirit.size = 0.5 + 4.5 * pow(10, rand_range(0, 2)) / 100


# Spawn enemies randomly according to scenery
func spawn_enemy():
	var enemy
	match scenery:
		Scenery.heaven:
			enemy = Angel.instance()
		Scenery.hell:
			enemy = Demon.instance()

	var dir = Global.random_vec2()
	enemies.add_child(enemy)
	enemy.global_position = dir * enemy_spawn_radius + player.global_position

func set_scenery(new_scenery):
	if scenery == new_scenery:
		return

	scenery = new_scenery
	match scenery:
		Scenery.hell:
			Global.play_music(Global.Music.hell)
		Scenery.heaven:
			Global.play_music(Global.Music.heaven)
		Scenery.safezone:
			Global.play_music(Global.Music.welcome)



func check_scenery():
	var y = player.global_position.y
	# Entered hell
	if y > 0:
		self.scenery = Scenery.hell
	# Heaven
	else:
		self.scenery = Scenery.heaven


func _process(delta):
	if Input.is_action_just_pressed("reset"):
		fade_to_black("restart")


func update_world():
	if not has_left_safe_area:
		return

	var delta = OS.get_ticks_msec() / 1000.0 - last_world_update
	last_world_update += delta

	check_scenery()

	# Spawn spirits
	randomize()
	if randf() < spirit_spaw_density * delta:
		spawn_spirit()

	# Spawn enemies
	randomize()
	if len(enemies.get_children()) < enemy_spawn_limit and randf() < enemy_spawn_density * delta:
		spawn_enemy()

	# Remove far away spirits
	for spirit in spirits.get_children():
		if spirit.global_position.distance_squared_to(player.global_position) > spirit_spawn_radius * spirit_spawn_radius * 2:
			spirit.queue_free()

	# Remove far away enemies
	for enemy in enemies.get_children():
		if enemy.global_position.distance_squared_to(player.global_position) > enemy_spawn_radius * enemy_spawn_radius * 2:
			enemy.queue_free()


func _on_SafeArea_body_exited(body:Node):
	if body.is_in_group("player"):
		has_left_safe_area = true


func _on_SafeArea_body_entered(body:Node):
	if body.is_in_group("player"):
		has_left_safe_area = false
		self.scenery = Scenery.safezone


# Game begins
func add_tutorial_barrier(body: Node):
	if not body == player:
		return

	# Add barrier to prevent player going back
	var barrier = $RemoveLater/Fence6
	barrier.enabled = true

	# Dispose of tutorial
	$Area2D.queue_free()
	Global.delete_children($Fences)
	Global.delete_children($Spirits)
	Global.delete_children($Orbs)
	Global.delete_children($Enemies)
	$Clouds.queue_free()
