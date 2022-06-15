extends Node2D

export(int) var wander_range = 1000
onready var start_position = global_position
onready var target_position = global_position
onready var timer = $Timer

func _ready():
	update_target_position()

func update_target_position():
	print("its tryinbg man")
	print(target_position)
	var target_vector = Vector2(rand_range(-wander_range, wander_range), rand_range(-wander_range, wander_range))
	target_position = start_position + target_vector

func _on_Timer_timeout():
	update_target_position()

func start_wander_timer(duration):
	print("itbs trni mna")
	timer.start(duration)

func get_time_left():
	return timer.time_left
