extends Area2D #死区
@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	timer.start()
	pass 

#重新加载整个游戏
func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	pass 
