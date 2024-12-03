extends PanelContainer

@onready var label = $VBoxContainer/ScrollContainer/VBoxContainer/Label


# 声明一个 HTTPRequest 节点
@onready var http_request: HTTPRequest = HTTPRequest.new()

func _ready():
	# 将 HTTPRequest 节点添加到场景树中
	add_child(http_request)

	# 将 "request_completed" 信号连接到自定义方法
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))

	# 发出 GET 请求到指定的 URL
	var url = "https://api.shumengya.top/gonggaolan/gonggaolan.php?by=history&from=kkframenew"
	var error = http_request.request(url)

	# 检查请求是否成功
	if error != OK:
		print("请求时发生错误: %s" % str(error))

# 当 HTTP 请求完成时调用此方法
func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray):
	# 将响应主体从 PackedByteArray 转换为字符串
	var response_body = body.get_string_from_utf8()

	# 打印响应代码和主体内容
	print("响应代码: %d" % response_code)
	print("响应内容: %s" % response_body)
	label.text = response_body


func _on_title_meta_clicked(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		print("Opened link '%s' successfully!" % meta)
	else:
		print("Failed opening the link '%s'!" % meta)
	pass 


func _on_button_pressed():
	hide()
	pass 
