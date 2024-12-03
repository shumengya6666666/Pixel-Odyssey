extends Area2D


func _on_body_entered(body):
	call_deferred("_change_scene")
	World.level += 1

func _change_scene():
	get_tree().change_scene_to_file("res://Main/game.tscn")
