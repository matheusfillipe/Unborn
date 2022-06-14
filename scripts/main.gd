extends Node2D

var Spirit = preload("res://scenes/Spirit.tscn")
var Bubble = preload("res://scenes/TextBubble.tscn")

onready var player = $Player
onready var overlay = $FadeInHack
onready var tween = $Tween
onready var spirits = $Spirits

export(float, 1, 10000) var spirit_spawn_radius = 1000.0
export(float, 0, 2) var spirit_spaw_density = 2

func _ready():

	# Pause and create transition effect on the beginning
	overlay.visible = true
	yield(get_tree().create_timer(1, false), "timeout")
	overlay.visible = false


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

# Spawn spirits randomly
func spawn_spirit():
	var dir = Global.random_vec2()
	var spirit = Spirit.instance()

	var color_chances = [
		0.5,  # WHITE
		0.05,  # BLACK
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

	spirit.start_color = i
	spirits.add_child(spirit)
	spirit.global_position = dir * spirit_spawn_radius + player.global_position
	spirit.velocity = - dir * rand_range(50, 500)
	spirit.noise_amplitude = rand_range(1, 10)
	spirit.noise_speed = rand_range(2, 20)
	spirit.size = 0.5 + 4.5 * pow(10, rand_range(0, 2)) / 100
	print(spirit.size)

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		fade_to_black("restart")


	# Spawn spirits
	randomize()
	if randf() < spirit_spaw_density * delta:
		spawn_spirit()

	# Remove far away spirits
	for spirit in spirits.get_children():
		if spirit.global_position.distance_squared_to(player.global_position) > spirit_spawn_radius * spirit_spawn_radius * 2:
			spirit.queue_free()
