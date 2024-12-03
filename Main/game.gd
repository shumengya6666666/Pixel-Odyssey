extends Node2D

#初始化关卡
@onready var test2 = preload("res://Maps/TestMap2.tscn").instantiate()
@onready var level1 = preload("res://Maps/Level1.tscn").instantiate()
@onready var level2 = preload("res://Maps/Level2.tscn").instantiate()
@onready var level3 = preload("res://Maps/Level3.tscn").instantiate()
@onready var level4 = preload("res://Maps/TDLevel1.tscn").instantiate()
@onready var level5 = preload("res://Maps/TestMap3.tscn").instantiate()
#@onready var level1 = preload("res://Maps/Level1.tscn").instantiate()
#@onready var level1 = preload("res://Maps/Level1.tscn").instantiate()
#@onready var level1 = preload("res://Maps/Level1.tscn").instantiate()
#@onready var level1 = preload("res://Maps/Level1.tscn").instantiate()


func _ready():
	match World.level:
		0:
			self.add_child(test2)
			pass
		1:
			self.add_child(level1)
			pass
		2:
			self.add_child(level2)
			pass
		3:
			self.add_child(level3)
			pass
		4:
			self.add_child(level4)
			pass
		5:
			self.add_child(level5)
			pass
		_:
			self.add_child(test2)
			pass
	pass
