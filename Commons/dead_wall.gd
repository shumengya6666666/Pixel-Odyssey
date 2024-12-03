extends Area2D


func _on_body_entered(body):
#	if body is CharacterBody2D:
	print(body) 

	if body.has_node("Healthbar"):
		var enemyhealth = body.get_node("Healthbar")
		if enemyhealth.has_method("take_damage"):
			enemyhealth.take_damage(10000000)
			enemyhealth.take_damage(10000000)

