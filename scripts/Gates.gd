tool
extends StaticBody2D

# This is the actual length you want it to tile into
export(float) var length = 41

# This is the texture length in godot units. Take care not to set wrong
export(float) var texture_length = 20.5

# Is this wall breakable?
export(bool) var breakable = false setget set_break

onready var shape = $CollisionShape2D
onready var texture = $TextureRect
onready var animation = $AnimationPlayer
onready var particles = $Particles2D
onready var initial_texture_width = $TextureRect.texture.get_width()
onready var audio = $AudioStreamPlayer2D

var break_particles = []

func extend(_length: float):
	_length = _length/2
	shape.shape.extents.x = _length
	shape.position.x = _length
	texture.margin_right = _length / texture_length * initial_texture_width

	# Add extra particles
	for p in break_particles:
		p.queue_free()
	break_particles = []

	_length = 2 * _length
	var num = ceil(_length / float(texture_length))
	particles.position.x = _length / 2 / num
	for i in range(1, num - 1):
		var p = particles.duplicate()
		add_child(p)
		p.position.x = (i+1) * _length / num
		break_particles.append(p)


func _process(_delta):
	if Engine.editor_hint :
		extend(length)

func _ready():
	if not Engine.editor_hint :
		if length > 0:
			extend(length)

func hit(_body: Node):
	if breakable:
		_break()

func _break():
	$CollisionShape2D.disabled = true
	particles.emitting = true
	for p in break_particles:
		p.emitting = true
	animation.play("break")
	audio.play()
	yield(animation, "animation_finished")
	queue_free()

func set_break(_breakable):
	breakable = _breakable
	if breakable:
		texture.modulate = Color(0, 2, 0, 0.9)
		add_to_group("hitable")
	else:
		texture.modulate = Color(1, 1, 1, 1)
		if is_in_group("hitable"):
			remove_from_group("hitable")

func set_enabled(enabled):
	$CollisionShape2D.disabled = not enabled
