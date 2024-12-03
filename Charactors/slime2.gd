extends "res://Charactors/slime.gd"

func attack(bodyhealth,body):
	# 这里是攻击逻辑
	print("攻击玩家！")
	bodyhealth.take_damage(100)
	
	if body is CharacterBody2D or body is RigidBody2D:
		# 如果 body 是一个具有 velocity 属性的节点
		var knockback_direction = (body.global_position - global_position).normalized()
		var knockback_strength = 200.0
		body.velocity += knockback_direction * knockback_strength
		#flash_red(body)
		body.player_hit()
	elif body is Area2D:
		# 如果 body 是 Area2D 或其他类型
		print("Area2D 类型的节点不具备 velocity 属性，无法应用击退效果。")
	else:
		print("传入的 body 类型无法识别。")
		
	explode()
	animated_sprite_2d.hide()
	await get_tree().create_timer(0.5).timeout
	health_bar.take_damage(1000)
	pass
