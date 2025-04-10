extends TaloLoadable

func on_loaded(data: Dictionary):
	handle_destroyed(data)

func _on_area_2d_body_entered(body :Node2D) -> void:
	queue_free()
	body.find_child("Loadable").on_star_pickup()
