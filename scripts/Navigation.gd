extends Navigation2D

onready var navpolygon = $NavigationPolygonInstance
var detection_shape: CollisionShape2D
var init_polygon

func _ready():
	# Make it so it has the detection shape
	var newpolygon = PoolVector2Array()
	var polygon = NavigationPolygon.new()
	var n_vertex = 32
	# HACK multiply by then to avoid concave polygons...
	var r = detection_shape.shape.radius * 10
	var c = detection_shape.global_position

	# Create a n-gon
	var i = 0
	while i < n_vertex:
		var angle = 2 * i * PI / n_vertex
		newpolygon.append(Vector2(cos(angle) * r, sin(angle) * r) + c)
		i+=1

	init_polygon = newpolygon
	polygon.add_outline(newpolygon)
	polygon.make_polygons_from_outlines()
	navpolygon.set_navigation_polygon(polygon)

	updt()

func update_polygon(collision: CollisionShape2D):
	var newpolygon = PoolVector2Array()
	var shape = collision.shape
	var polygon = NavigationPolygon.new()
	var rec = shape.extents

	newpolygon.append(Vector2(rec.x/2, rec.y/2) + collision.global_position)
	newpolygon.append(Vector2(-rec.x/2, rec.y/2) + collision.global_position)
	newpolygon.append(Vector2(-rec.x/2, -rec.y/2) + collision.global_position)
	newpolygon.append(Vector2(rec.x/2, -rec.y/2) + collision.global_position)


	polygon.add_outline(init_polygon)
	polygon.add_outline(newpolygon)
	polygon.make_polygons_from_outlines()
	navpolygon.set_navigation_polygon(polygon)

	updt()

# HACK godot needs this and the whole navigation thing is basically still a wip and will
# be only really ready in 4.x
func updt():
	navpolygon.enabled = false
	navpolygon.enabled = true
