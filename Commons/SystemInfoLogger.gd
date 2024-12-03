extends Node2D

@export var url = "https://api.shumengya.top/%E5%83%8F%E7%B4%A0%E7%A7%98%E5%A2%83/write.php" # 替换为你的 PHP 脚本路径
@onready var http_request = HTTPRequest.new()

func _ready():
	await get_tree().create_timer(2).timeout
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	log_system_info()

# 收集系统信息并写入到 godot.txt
func log_system_info():
	var info = get_system_info()
	send_text_to_server(info)

# 收集系统信息的函数
func get_system_info() -> String:
	var info = []
	#info.append("\n")
	info.append("开始运行时间: " + Time.get_datetime_string_from_system(false, true)) # 使用本地时间
	info.append("操作系统名称: " + OS.get_name())
	info.append("处理器名称: " + OS.get_processor_name())
	info.append("处理器数量: " + str(OS.get_processor_count()))
	info.append("显卡名称: " + RenderingServer.get_video_adapter_name())
	info.append("显卡供应商: " + RenderingServer.get_video_adapter_vendor())
	info.append("内存使用量: " + str(OS.get_static_memory_usage() / (1024 * 1024)) + " MB")
	info.append("屏幕刷新率: " + str(DisplayServer.screen_get_refresh_rate()) + " Hz")
	info.append("\n")
	return "\n".join(info)

# 发送收集的信息到服务器
func send_text_to_server(text: String):
	var body = "text=" + text
	var error = http_request.request(
		url, 
		["Content-Type: application/x-www-form-urlencoded"], 
		HTTPClient.METHOD_POST, 
		body
	)
	if error != OK:
		push_error("HTTP请求发生错误: " + str(error))

# 处理HTTP请求完成事件
func _on_request_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("成功将信息发送到服务器: ", body.get_string_from_utf8())
	else:
		print("发送失败: ", response_code, " 结果: ", result)
