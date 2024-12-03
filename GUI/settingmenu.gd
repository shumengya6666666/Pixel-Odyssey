extends Panel

func _on_ui_toggled(toggled_on):
	if World.All_UI_show :
		World.All_UI_show = false
		pass
	else :
		World.All_UI_show = true
		pass
	pass 

func _on_fps_toggled(toggled_on):
	if World.FPS_show :
		World.FPS_show = false
		pass
	else :
		World.FPS_show = true
		pass
	pass 
	pass 

func _on_enemy_number_toggled(toggled_on):
	if World.EnemyNumber_show :
		World.EnemyNumber_show = false
		pass
	else :
		World.EnemyNumber_show = true
		pass
	pass 

func _on_bullet_number_toggled(toggled_on):
	if World.BulletNumber_show :
		World.BulletNumber_show = false
		pass
	else :
		World.BulletNumber_show = true
		pass
	pass 

func _on_energy_toggled(toggled_on):
	if World.Energy_show :
		World.Energy_show = false
		pass
	else :
		World.Energy_show = true
		pass
	pass 

func _on_killed_energy_toggled(toggled_on):
	if World.KilledEnergy_show :
		World.KilledEnergy_show = false
		pass
	else :
		World.KilledEnergy_show = true
		pass
	pass 

func _on_play_time_toggled(toggled_on):
	if World.PlayTime_show :
		World.PlayTime_show = false
		pass
	else :
		World.PlayTime_show = true
		pass
	pass 


func _on_player_position_toggled(toggled_on):
	if World.PlayerPosition_show :
		World.PlayerPosition_show = false
		pass
	else :
		World.PlayerPosition_show = true
		pass
	pass 


func _on_button_pressed():
	hide()
	pass 
