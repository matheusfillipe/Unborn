extends Navigation2D

onready var navpolygon = $NavigationPolygonInstance
var detection_shape: CollisionShape2D

func _ready():
	# Make it so it has the detection shape
	var newpolygon = PoolVector2Array()
	var polygon = navpolygon.get_navigation_polygon()
	var n_vertex = 32
	var r = detection_shape.shape.radius
	var c = detection_shape.global_position

	# Create a n-gon
	var i = 0
	while i < n_vertex:
		var angle = 2 * i * PI / n_vertex
		newpolygon.append(Vector2(cos(angle) * r, sin(angle) * r) + c)
		i+=1

	polygon.add_outline(newpolygon)
	polygon.make_polygons_from_outlines()
	navpolygon.set_navigation_polygon(polygon)

	updt()

func update_polygon(shape: Shape2D):
	var newpolygon = PoolVector2Array()
	var polygon = navpolygon.get_navigation_polygon()
	var polygon_bp = shape.get_polygon()

	var polygon_transform = shape.get_global_transform()
	for vertex in polygon_bp:
		newpolygon.append(polygon_transform.xform(vertex))

	polygon.add_outline(newpolygon)
	polygon.make_polygons_from_outlines(polygon)
	navpolygon.set_navigation_polygon(polygon)

	updt()

# HACK godot needs this and the whole navigation thing is basically still a wip and will
# be only really ready in 4.x
func updt():
	navpolygon.enabled = false
	navpolygon.enabled = true
