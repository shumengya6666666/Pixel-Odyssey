extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_size"):
		body.set_size(2,10)
		pass
	queue_free()
	pass 
