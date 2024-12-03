##一个访问腾讯微云的笔记内容的脚本
##我用来作为游戏的公告栏
##相当于一个半成品，有bug，只能识别中文，输入英文会显示出错，气死我了

extends Node

# 声明一个 AwaitableHTTPRequest 类型的变量，用于执行 HTTP 请求
var http: AwaitableHTTPRequest

# _ready() 是 Godot 中的一个回调函数，当节点及其子节点完成初始化时被调用
func _ready() -> void:
	# 创建一个新的 AwaitableHTTPRequest 实例，并将其赋值给 http 变量
	http = AwaitableHTTPRequest.new()
	
	# 将创建的 http 节点添加到当前节点的子节点树中，以便它能够正常工作
	add_child(http)
	
	# 使用 async_request 方法发送异步 HTTP GET 请求，并等待请求完成
	# 访问的 URL 是 'https://share.weiyun.com/nn5JzDT5'
	var result := await http.async_request('https://share.weiyun.com/nn5JzDT5')
	
	# 检查 HTTP 请求是否成功
	if result.success:
		# 请求成功时，打印返回的响应体内容
		# 这里注释掉了打印状态码和响应头的代码，仅保留打印响应体的部分
		# print("Status Code: ", result.status_code)  # 输出状态码
		# print("Headers: ", result.headers)          # 输出响应头信息
		# print("Body: ", result.body)                # 输出响应体内容
		
		# 调用解析函数 extract_html_content 来提取响应体中的 html_content 内容
		var html_content = extract_html_content(result.body)
		# 打印提取出的 html_content 内容
		print("获取网页内容: ", html_content)  # 输出解析后的 html_content
		
	else:
		# 如果请求失败，打印错误代码
		print("获取网页内容失败，原因: ", result._error)

# 定义一个函数 extract_html_content，用于从 HTTP 响应体中提取 html_content 内容
func extract_html_content(response_body: String) -> String:
	# 定义正则表达式模式，用于匹配 html_content 的内容
	var pattern = r'"html_content":"(\\u003C[^"]+)"'
	# 创建一个新的 RegEx 实例
	var regex = RegEx.new()
	# 编译正则表达式模式
	regex.compile(pattern)
	
	# 在响应体中搜索匹配项
	var match = regex.search(response_body)
	
	# 如果找到匹配项，并且匹配组的数量大于 0
	if match and match.get_group_count() > 0:
		# 获取匹配的字符串内容，即 html_content 的值
		var html_content = match.get_string(1)
		# 将 Unicode 转义字符 \\u003C 和 \\u003E 替换为实际的 < 和 > 字符
		html_content = html_content.replace("\\u003C", "<").replace("\\u003E", ">")
		# 移除 <p> 和 </p> 标签，仅保留内部的文本内容
		html_content = html_content.replace("<p>", "").replace("</p>", "")
		# 返回提取和处理后的 html_content 内容
		return html_content
	else:
		# 如果没有找到匹配项，返回 "No match found"
		return "No match found"
