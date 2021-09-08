extends Navigation2D

func _ready():
	
	if !SignalHandler.edited_navigation_polygon:
		for static_body in get_tree().get_nodes_in_group("StaticBodies"):
			cut_static_bodie_collision(static_body.get_child(0))
		SignalHandler.edited_navigation_polygon = true

func cut_static_bodie_collision(collision):
	var newpolygon = PoolVector2Array()
	var polygon = $NavigationPolygonInstance.get_navigation_polygon()
	var polygon_transform = collision.get_global_transform()
	var polygon_bp = collision.get_polygon()
	for vertex in polygon_bp:
		newpolygon.append(polygon_transform.xform(vertex))
	polygon.add_outline(newpolygon)
	polygon.make_polygons_from_outlines()
	$NavigationPolygonInstance.set_navigation_polygon(polygon)
	$NavigationPolygonInstance.enabled = false
	$NavigationPolygonInstance.enabled = true
