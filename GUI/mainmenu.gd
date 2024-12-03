extends Panel

@onready var notice_board = $NoticeBoard
@onready var setting = $setting
@onready var click = $click

func _on_play_button_pressed():
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://GUI/gamemenu.tscn")

	pass 

func _on_setting_button_pressed():
	click.play()
	await get_tree().create_timer(0.2).timeout
	setting.show()
	pass 

func _on_update_button_pressed():
	click.play()
	await get_tree().create_timer(0.2).timeout
	notice_board.show()
	pass 

func _on_about_button_pressed():
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://GUI/aboutmenu.tscn")

	pass 

func _on_exit_button_pressed():
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
	pass
	
