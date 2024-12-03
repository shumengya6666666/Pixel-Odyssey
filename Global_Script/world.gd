extends Node
#杀死敌人数量
var  killed_enemy :int = 0
#剩余子弹数量
var  bullet_number :int = 1000
#当前关卡
var level :int = 1
var time1 :int = 0

#UI设置
var All_UI_show :bool = true
var FPS_show :bool = true
var EnemyNumber_show :bool = true
var BulletNumber_show :bool = true
var Energy_show :bool = true
var KilledEnergy_show :bool = true
var PlayTime_show :bool = true
var PlayerPosition_show :bool = true

var BasePosition : Vector2

func _process(delta):
	time1 += 1
	if  time1 >= 100:
		bullet_number += 1
		time1 = 0
		pass
	
	pass
