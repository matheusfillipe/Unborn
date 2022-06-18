extends Node2D
tool

# TODO tile it by dragging starting points to center
# clip starting points that are out of the rectangle border
# Add random breakables that are small

# No o fence
var Fence = preload("res://scenes/Fence.tscn")

var fences = []
var end_points = PoolVector2Array()
var polygon = []
var cut_shapes = []
var astar = AStar.new()
var generated = false
var generate_thread

export(float) var size = 5000
export(float) var border = 500
export(float) var y_limit = 0
export(float) var x_limit = 0
export(float) var ammount = 10
export(float) var min_len = 200
export(float) var max_len = 1000
export(float) var keep_gap = 50
export(float, 0, 1) var breakable_chance = 0.1
export(float) var breakable_min_size = 50
export(float) var breakable_max_size = 100
export(float, 0, 360) var line_spread = 1
export(PoolVector2Array) var starting_points

signal player_exited
signal player_entered

const MAX_GAP_CORRECTION_ATTEMPTS = 10
const CENTER_DRAG_COUNT = 3
const ANGLES = [0, PI/4, PI/2, 3*PI/4, PI, 5*PI/4, 3*PI/2, 7*PI/4]

func rvec(l: float, from: Vector2, last: Vector2, drag_to_center: bool = false) -> Vector2:
	if drag_to_center:
		var dir = (from - global_position).normalized()
		var angle = dir.angle_to(Vector2(1, 0))
		for a in ANGLES:
			if angle < a:
				angle = a
				break
		return Vector2(cos(angle), sin(angle)) * l

	var idx = int(rand_range(0, 7.5))
	var angle = ANGLES[idx]
	var vec = Vector2(cos(angle), sin(angle))

	var to = from + vec * l
	if from != last and (to - last).angle_to(from - last) > deg2rad(line_spread):
		return rvec(l, from, last)
	return vec * l

func v3(vec: Vector2) -> Vector3:
	return Vector3(vec.x, vec.y, 0)

func v2(vec: Vector3) -> Vector2:
	return Vector2(vec.x, vec.y)

func less_than_min_gap(pt: Vector2) -> bool:
	var id = astar.get_closest_point(v3(pt), true)
	if id < 0:
		return false
	var vec = v2(astar.get_point_position(id))
	return vec.distance_squared_to(pt) < keep_gap * keep_gap


func random_points(from: Vector2, drag_to_center: bool = false) -> Array:
	randomize()
	var points = []
	var last = from
	var dccounter = 0
	points.append(from)
	astar.add_point(len(astar.get_points()), v3(from))

	for _i in range(int(rand_range(size/max_len, size/min_len))):
		if dccounter >= CENTER_DRAG_COUNT:
			drag_to_center = false

		var to = from + rvec(rand_range(min_len, max_len), from, last, drag_to_center)

		var j = 0
		while less_than_min_gap(to) and j < MAX_GAP_CORRECTION_ATTEMPTS:
			to = from + rvec(rand_range(min_len, max_len), from, last, drag_to_center)
			j+=1

		dccounter += 1

		# Clip if out of the rect
		if Geometry.is_point_in_polygon(to, polygon):
			var must_break = false
			for pol in cut_shapes:
				if not Geometry.is_point_in_polygon(to, pol):
					continue
				must_break = true
				var ip = Geometry.intersect_polyline_with_polygon_2d(
					[from, to],
					pol)

				if len(ip) > 0:
					for rpt in ip[0]:
						if rpt != from and rpt != to:
							to = rpt
				break

			points.append(to)
			astar.add_point(len(astar.get_points()), v3(to))

			if must_break:
				break

		else:
			var ip = Geometry.intersect_polyline_with_polygon_2d(
				[from, to],
				polygon)

			if len(ip) > 0:
				for rpt in ip[0]:
					if rpt != from and rpt != to:
						to = rpt
				points.append(to)
				end_points.append(to)
				astar.add_point(len(astar.get_points()), v3(to))
			break

		last = from
		from = to
	return points


func add_fence(points: Array):
	var fence = Fence.instance()
	var relative_points = []
	for gpt in points:
		relative_points.append(gpt - 2 * global_position)

	fence.points = relative_points
	fence.global_position = global_position
	call_deferred("add_child", fence)
	# add_child(fence)
	call_deferred("_add_fence", fence)

func _add_fence(fence):
	for gate in fence.parts:
		if abs(gate.global_position.x - x_limit) < 1 or abs(gate.global_position.y - y_limit) < 1:
			break
		# Add a breakable fence in between
		randomize()
		if randf() < breakable_chance:
			gate.call_deferred("set_break", true)

	fences.append(fence)

func _ready():
	# Make everything in global position then convert later
	$Area2D/CollisionShape2D.shape.extents.x = size + border
	$Area2D/CollisionShape2D.shape.extents.y = size + border

	# Define polygon
	var _polygon = [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
	for pt in _polygon:
		polygon.append(global_position + pt * size)

func _process(_delta):
	if Engine.editor_hint :
		_ready()

func generate():
	if generated:
		return
	generate_thread = Thread.new()
	generate_thread.start(self, "_thread_function")
	# _thread_function(1)

func _thread_function(_a):
	var lines = []
	var _cut_shapes = Global.get_children_with_type(self, CollisionPolygon2D)
	for s in _cut_shapes:
		cut_shapes.append(s.polygon)


	# Always separate
	var topr = Vector2(global_position.x - size, global_position.y - size)
	var bottoml = Vector2(global_position.x + size, global_position.y + size)

	if topr.y < y_limit and bottoml.y > y_limit:
		lines.append(
			[
				Vector2(global_position.x - size, y_limit),
				Vector2(global_position.x + size, y_limit),
			])


	if topr.x < x_limit and bottoml.x > x_limit:
		lines.append(
			[
				Vector2(x_limit, global_position.y + size),
				Vector2(x_limit, global_position.y - size),
			])


	# Generate random fences from starting points
	for pt in starting_points:
		var addpt = pt
		if not Geometry.is_point_in_polygon(pt, polygon):
			continue
			# var ip = Geometry.intersect_polyline_with_polygon_2d(
			# 	[pt, global_position],
			# 	polygon)

			# if len(ip) < 1:
			# 	continue

			# for rpt in ip[0]:
			# 	if rpt != global_position:
			# 		addpt = rpt

		end_points.append(addpt)
		astar.add_point(len(astar.get_points()), v3(addpt))
		lines.append(random_points(addpt, true))

	# generate more until you have ammount
	if len(starting_points) < ammount:
		for _i in range(ammount - len(starting_points)):
			randomize()
			var pt = Vector2(
				rand_range(global_position.x - size, global_position.x + size),
				rand_range(global_position.y - size, global_position.y + size))
			lines.append(random_points(pt))

	for points in lines:
		add_fence(points)

	generated = true


func _on_Area2D_body_exited(body:Node):
	if body.is_in_group("player"):
		emit_signal("player_exited", self)

func _on_Area2D_body_entered(body:Node):
	if body.is_in_group("player"):
		emit_signal("player_entered", self)

# TODO remove
func debug_orb(pos):
	# TODO delete
	var Orb = preload("res://scenes/orb.tscn")
	var n = Orb.instance()
	n.start_brightness = 10000
	n.start_size = 10
	call_deferred("add_child", n)
	n.global_position = pos



func _exit_tree():
	if is_instance_valid(generate_thread):
		generate_thread.wait_to_finish()
