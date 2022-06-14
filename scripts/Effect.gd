extends Node2D

signal ended

onready var animation = $AnimationPlayer
onready var timer = $Timer

export(PackedScene) var spawn
export(bool) var must_spawn = false

onready var spawn_parent = get_tree().get_current_scene()
var spawn_props = {}
var has_spawn = false

signal body_entered

func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("ended")
	_on_Timer_timeout()
	queue_free()

func _on_Timer_timeout():
	if must_spawn:
		if has_spawn:
			return
		has_spawn = true
		var node = spawn.instance()
		for key in spawn_props:
			var value = spawn_props[key]
			node.set(key, value)
		node.global_position = global_position
		spawn_parent.add_child(node)


func _on_Area2D_body_entered(body:Node):
	emit_signal("body_entered", body)


func _on_Area2D_area_entered(body: Area2D):
	emit_signal("body_entered", body)
