extends Node2D

# TODO
#  --  Make the enemies pathfind

var Spirit = preload("res://scenes/Spirit.tscn")
var Demon = preload("res://scenes/Demon.tscn")
var Angel = preload("res://scenes/Angel.tscn")
var Bubble = preload("res://scenes/TextBubble.tscn")
var Explosion = preload("res://effects/Explosion.tscn")
var ShockWave = preload("res://effects/ShockWave.tscn")
var Fence = preload("res://scenes/Fence.tscn")
var SceneryGenerator = preload("res://scenes/SceneryGenerator.tscn")
var SceneryGeneratorClass = preload("res://scripts/SceneryGenerator.gd")
var Plot = preload("res://scripts/Plot.gd")

onready var player = $Player
onready var overlay = $FadeInHack
onready var tween = $Tween
onready var spirits = $Spirits
onready var enemies = $Enemies
onready var camera = $Camera2D
onready var safearea = $Bridge/SafeArea
onready var environment = $WorldEnvironment.environment
onready var normal_exposure = $WorldEnvironment.environment.auto_exposure_min_luma
onready var scenery_gen = $SceneryGen
onready var hell_map = $SceneryGen/SceneryGenerator
onready var heaven_map = $SceneryGen/SceneryGenerator2
onready var checkpoints = $Checkpoints
onready var pausebtn = $Control/Control/PauseButton

onready var plot = Plot.new()

onready var initial_hell_map_pos = hell_map.global_position
onready var initial_heaven_map_pos = heaven_map.global_position

var has_left_safe_area = false
var last_world_update = 0.0
var current_map

export(float, 1, 10000) var spirit_spawn_radius = 1000.0
export(float, 0, 5) var spirit_spaw_density = 2
export(int, 1, 1000) var spirit_spawn_limit = 20
export(int, 1, 1000) var spirit_limit_per_map = 3
export(float, 1, 10000) var enemy_spawn_radius = 1000.0
export(float, 0, 2) var enemy_spawn_density = 2
export(int, 1, 100) var enemy_spawn_limit = 4
export(float, 0, 1) var show_progress_chance = 0.2
export(float, 0, 1) var spirit_random_message_chance = 0.05

export(float) var heaven_y_limit = -1200
export(float) var hell_y_limit = 0

export(bool) var force_mobile = false

enum Scenery {
	safezone,
	hell,
	heaven
}

# Current scenery
var scenery = Scenery.safezone setget set_scenery
var grid = {}
var actions = {0: false}
var checkpoint_locked = false

func _ready():
	var sprites = []
	for sprite in Global.get_children_with_type(self, Sprite):
		if sprite.visible and sprite != overlay:
			sprites.append(sprite)
			sprite.visible = false

	player.connect("spirit_kill", self, "on_player_spirit_kill")
	bind_sceneries()
	bind_checkpoints()


	if Global.checkpoint != null:
		show_bridge()

	# platform specific adjust
	match OS.get_name():
		"Android":
			environment.auto_exposure_enabled = false
			environment.glow_enabled = false
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

	Global.is_mobile = Global.is_mobile or force_mobile

	if Global.is_mobile:
		pausebtn.visible = true


	# Start
	Global.play_music_once(Global.Music.entrance)
	player.connect("size_changed", self, "adjust_zoom")
	player.connect("died", self, "player_died")
	compile_shaders()

	# Pause and create transition effect on the beginning
	overlay.visible = true
	yield(get_tree().create_timer(1, false), "timeout")
	overlay.visible = false
	for sprite in sprites:
		sprite.visible = true

	yield(get_tree().create_timer(7, false), "timeout")
	if scenery == Scenery.safezone:
		Global.play_music(Global.Music.welcome)


# HACK Avoid hickup for when effects are used first time. godot 3.5 has something better for this
func compile_shaders():
	var explosion = Explosion.instance()
	explosion.global_position = Vector2(-10000, 10000)
	add_child(explosion)

	var node = ShockWave.instance()
	node.global_position = Vector2(-10000, 10000)
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
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func player_died(message):
	Global.play(Global.SFX.death)
	var time = max(Global.read_time(message) + 1, 4)
	Global.popup(message, time)
	yield(get_tree().create_timer(time, false), "timeout")

	# HACK this shouldn't be manage by the player. use the scenery
	if "hell" in message:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/Hell.tscn")
	elif "heaven" in message:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/Heaven.tscn")
	else:
		restart()

# Total spirits in the current map
func count_map_spirits():
	var map = initialize_counter()
	var sum = 0
	for c in Global.spirit_counter[map][scenery]:
		sum += Global.spirit_counter[map][scenery][c]
	return sum

# Total spirits for the passed in scenery and color
func count_spirits(scn, col):
	var sum = 0
	for map in Global.spirit_counter:
		if scn in Global.spirit_counter[map]:
			if col in Global.spirit_counter[map][scn]:
				sum += Global.spirit_counter[map][scn][col]
	return sum

# Bare total
func count_total_spirits():
	var sum = 0
	for map in Global.spirit_counter:
		for scn in Global.spirit_counter[map]:
			for c in Global.spirit_counter[map][scn]:
				sum += Global.spirit_counter[map][scn][c]
	return sum

# Spawn spirits randomly
func spawn_spirit():
	# Don't spawn if player kill reached map limit
	if count_map_spirits() >= spirit_limit_per_map:
		return

	var color_chances = [
		0.5,  # WHITE
		0.0,  # BLACK
		0.0,  # BLUE
		0.08,  # GREEN
		0.27,  # YELLOW
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


func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		fade_to_black("restart")


	# Dynamic coloring
	var y = player.global_position.y
	var background = Color(0.113725, 0.482353, 0.901961)
	var color = Color(1, 1, 1, 1)

	# heaven
	if y < -1000:
		var dest = Color(0.1, 0.5, 0.8, 1)
		var v = min(abs(y+1000)/1000, 1)
		color = lerp(color, dest, v)

		dest = Color(0.2, 0.4, 0.6)
		background = lerp(color, dest, v)

	#hell
	elif y > 100:
		var dest = Color(0.6, 0.3, 0.3, 1)
		var v = min(abs(y-100)/1000, 1)
		color = lerp(color, dest, v)

		dest = Color(0.2, 0.1, 0.1, 1)
		background = lerp(color, dest, v)

	if has_left_safe_area:
		if y > 500:
			environment.auto_exposure_min_luma = 0.1
		else:
			environment.auto_exposure_min_luma = normal_exposure


	var sprite1 = $Camera2D/ParallaxBackground/ParallaxLayer/Sprite
	var sprite2 = $Camera2D/ParallaxBackground/ParallaxLayer2/Sprite2

	sprite1.modulate = color
	sprite2.modulate = color
	sprite1.material.set_shader_param("u_replacement_color", background)
	sprite2.material.set_shader_param("u_replacement_color", background)


func update_world():
	if not is_instance_valid(current_map):
		return

	if not has_left_safe_area:
		return

	var delta = OS.get_ticks_msec() / 1000.0 - last_world_update
	last_world_update += delta

	check_scenery()

	# Spawn spirits
	randomize()
	if len(spirits.get_children()) < spirit_spawn_limit and randf() < spirit_spaw_density * delta:
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
	var barrier = $Bridge/TutorialBarrier
	barrier.enabled = true

	# Dispose of tutorial
	$Area2D.queue_free()
	Global.delete_children($Fences)
	Global.delete_children($Spirits)
	Global.delete_children($Orbs)
	Global.delete_children($Enemies)
	$Backgrounds.queue_free()
	show_bridge()

func show_bridge():
	# $Checkpoints/Clouds.visible = true
	# $Checkpoints/Clouds2.visible = true
	# $Checkpoints/Clouds3.visible = true
	$Camera2D/ParallaxBackground/ParallaxLayer/Sprite.visible = true
	$Camera2D/ParallaxBackground/ParallaxLayer2/Sprite2.visible = true


func on_checkpoint(body: Node):
	if checkpoint_locked:
		return

	if not body == player:
		return

	# Add checkpoint
	Global.checkpoint = player.global_position
	Global.popup("Checkpoint!", 3)

	# Dont keep spamming
	checkpoint_locked = true
	yield(get_tree().create_timer(10, false), "timeout")
	checkpoint_locked = false


func initialize_counter(color=null):
	if not has_left_safe_area:
		return

	var map = current_map.global_position
	if not map in Global.spirit_counter:
		Global.spirit_counter[map] = {}
	if not scenery in Global.spirit_counter[map]:
		Global.spirit_counter[map][scenery] = {}

	if color != null and not color in Global.spirit_counter[map][scenery]:
		Global.spirit_counter[map][scenery][color] = 0

	return map


func on_player_spirit_kill(color, _size):
	if not has_left_safe_area:
		return

	var map = initialize_counter(color)
	Global.spirit_counter[map][scenery][color] += 1

	var total = count_total_spirits()

	# PLOT Game progress messages
	var n = plot.next_message()
	if n != -1 and total > n:
		var message = plot.pop_message(n)
		Global.popup(message, Global.read_time(message) + 3)
		return

	randomize()
	if randf() < spirit_random_message_chance and total > 5:
		var message = plot.random_messages[randi() % len(plot.random_messages)]
		Global.popup(message, Global.read_time(message) + 3)
		return

	# If not random spirits messages then we print progress randomly and check for win condition
	randomize()
	if randf() < show_progress_chance and total > 5:
		show_progress()

func show_progress():
	var goal = plot.goal
	var message = ""

	var place = scenery
	var col
	var count = 0

	for _col in goal[place]:
		var captured = count_spirits(place, _col)
		if captured < goal[place][_col]:
			col = plot.COLOR.keys()[_col]
			count = goal[place][_col] - captured

	if count <= 0:
		if check_completed(Scenery.hell) and check_completed(Scenery.heaven):
			return win()

		var goto = ""
		match place:
			Scenery.heaven:
				goto = "go down to hell"
			Scenery.hell:
				goto = "go up to heaven"

		message = "Your job here is done. You can now " + goto + ". I hope you find the way back..."
	else:
		message += "You still need " + str(count) + " "
		message += col + " spirits from "
		message += Plot.Scenery.keys()[place] + " to reincarnate"

	Global.popup(message, Global.read_time(message) + 3)


func check_completed(place):
	var goal = plot.goal
	for col in goal[place]:
		var captured = count_spirits(place, col)
		if captured < goal[place][col]:
			return false
	return true


#####
# Every time you enter a scenery 8 placeholders non generated are added around
# When you leave there is a delay and then it is removed
#####

# TODO refactor all those map variables into a single class
# TODO get rid of magical numbers

# Only adds if it is at a different position
func add_map(pos: Vector2, maps, freeing =  null):
	for other in maps:
		if other.global_position == pos and other != freeing:
			return

	var sgen = SceneryGenerator.instance()
	if is_instance_valid(current_map):
		sgen.starting_points = current_map.end_points

	var y = player.global_position.y
	if  y < -500:
		if pos.y > heaven_y_limit or pos.x < heaven_map.x_limit:
			sgen.queue_free()
			return

		sgen.from(heaven_map)
		sgen.x_limit = heaven_map.x_limit

		# Only the non first maps need y limits set because we need to enter
		if pos == initial_heaven_map_pos:
			sgen.y_limit = 0
		else:
			sgen.y_limit = heaven_y_limit
		heaven_map = sgen

	else:
		if pos.y < hell_y_limit or pos.x < hell_map.x_limit:
			sgen.queue_free()
			return

		sgen.from(hell_map)
		sgen.x_limit = hell_map.x_limit

		# Only the non first maps need y limits set because we need to enter
		if pos == initial_hell_map_pos:
			sgen.y_limit = -100
		else:
			sgen.y_limit = hell_y_limit
		hell_map = sgen


	sgen.global_position = pos

	scenery_gen.call_deferred("add_child", sgen)
	sgen.connect("player_entered", self, "player_entered_scenery_border")
	sgen.connect("player_exited", self, "player_exited_scenery_border")



func player_entered_scenery_border(sgen):
	# Populated entered map
	sgen.generate()
	current_map = sgen

	# Generate 8 waiting placeholders around
	if not scenery in grid:
		grid[scenery] = []

	var pos = sgen.global_position
	var maps = Global.get_children_with_type(scenery_gen, SceneryGeneratorClass)
	for d in [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]:
		var npos = pos + Vector2(d[0], d[1]) * sgen.size * 2
		add_map(npos, maps)


func player_exited_scenery_border(sgen):
	if sgen != current_map:
		var pos = sgen.global_position
		sgen.queue_free()
		var maps = Global.get_children_with_type(scenery_gen, SceneryGeneratorClass)
		add_map(pos, maps, sgen)


func bind_sceneries():
	for sgen in Global.get_children_with_type(scenery_gen, SceneryGeneratorClass):
		Global.sdisconnect(sgen, "player_entered", self, "player_entered_scenery_border")
		Global.sdisconnect(sgen, "player_exited", self, "player_exited_scenery_border")
		sgen.connect("player_entered", self, "player_entered_scenery_border")
		sgen.connect("player_exited", self, "player_exited_scenery_border")

func bind_checkpoints():
	for a in Global.get_children_with_type(checkpoints, Area2D):
		Global.sconnect(a, "body_entered", self, "on_checkpoint")


func act(b: Node):
	var t3 = get_node("Orbs/TutorialSpirit3")
	match b:
		t3:
			if actions[0]:
				return
			$Orbs/TutorialSpirit2.is_present = false
			b.tutorial_message = "There is no way back after this..."
			$Spirits/SpawnTutorialSpirit2.queue_free()
			actions[0] = true

func win():
	return get_tree().change_scene("res://scenes/Outro.tscn")


func _on_PauseButton_pressed():
	Global.toggle_pause()
