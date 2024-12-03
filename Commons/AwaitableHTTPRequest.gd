class_name AwaitableHTTPRequest
extends HTTPRequest
## 可等待的HTTP请求节点 v1.6.0，由 swark1n 和 [url=https://github.com/Swarkin/Godot-AwaitableHTTPRequest/graphs/contributors]贡献者们[/url] 提供。

# 当当前请求完成后发出信号，紧接着 [member is_requesting] 被设置为 false。
signal request_finished		

# 表示节点是否正在执行请求的布尔变量。
var is_requesting := false  

## 一个由 [method AwaitableHTTPRequest.async_request] 方法返回的数据类。
class HTTPResult extends RefCounted:
	# 返回 [method HTTPRequest.request] 错误，如果没有错误则返回 [constant Error.OK]。
	var _error: Error				

	# 返回 [HTTPRequest] 的结果状态，如果成功则返回 [constant HTTPRequest.RESULT_SUCCESS]。
	var _result: HTTPRequest.Result	

	# 检查 [member _error] 和 [member _result] 是否没有错误状态。
	# 注意: 如果 [member status_code] 大于等于 400，这并不会返回 false，详见 [code]https://developer.mozilla.org/en-US/docs/Web/HTTP/Status[/code]。
	var success: bool:				
		get: return true if (_error == OK and _result == HTTPRequest.RESULT_SUCCESS) else false

	# 响应的状态码（HTTP状态码）。
	var status_code: int			

	# 响应的头信息（HTTP头）。
	var headers: Dictionary			

	# 响应体内容作为 [String] 类型。
	var body: String:				
		get: return body_raw.get_string_from_utf8()

	# 响应体内容作为 [PackedByteArray] 类型。
	var body_raw: PackedByteArray	

	# 尝试将 [member body] 解析为 [Dictionary] 或 [Array] 类型，失败时返回 null。
	var json: Variant:				
		get: return JSON.parse_string(body)

	## 从 [enum @GlobalScope.Error] 错误码构建一个新的 [AwaitableHTTPRequest.HTTPResult] 实例。
	static func _from_error(err: Error) -> HTTPResult:
		var h := HTTPResult.new()
		h._error = err
		return h

	## 从 [signal HTTPRequest.request_completed] 返回的数组构建一个新的 [AwaitableHTTPRequest.HTTPResult] 实例。
	static func _from_array(a: Array) -> HTTPResult:
		var h := HTTPResult.new()
		# 忽略类型转换警告，强制转换为 HTTPRequest.Result 类型
		@warning_ignore('unsafe_cast') h._result = a[0] as HTTPRequest.Result
		# 忽略类型转换警告，强制转换为 int 类型
		@warning_ignore('unsafe_cast') h.status_code = a[1] as int
		# 忽略类型转换警告，强制转换为字典形式的头信息
		@warning_ignore('unsafe_cast') h.headers = _headers_to_dict(a[2] as PackedStringArray)
		# 忽略类型转换警告，强制转换为 PackedByteArray 类型的响应体
		@warning_ignore('unsafe_cast') h.body_raw = a[3] as PackedByteArray
		return h

	# 将头信息数组转换为字典格式。
	static func _headers_to_dict(headers_arr: PackedStringArray) -> Dictionary:
		var dict := {}
		# 遍历每个头信息项
		for h: String in headers_arr:
			# 根据 ":" 分割头信息键值对
			var split := h.split(':')
			# 去除多余空白后将键值对加入字典
			dict[split[0]] = split[1].strip_edges()

		return dict


## 执行一个可等待的 HTTP 请求。
##[br]用法示例:
##[codeblock]
##@export var http: AwaitableHTTPRequest
##
##func _ready() -> void:
##    var r := await http.async_request('https://api.github.com/users/swarkin')
##
##    if r.success:
##        print(r.status_code)              # 200
##        print(r.headers['Content-Type'])  # application/json
##        print(r.json['bio'])              # fox.
##[/codeblock]
func async_request(url: String, method := HTTPClient.Method.METHOD_GET, custom_headers := PackedStringArray(), request_body := '') -> HTTPResult:
	# 设置 is_requesting 为 true，表示开始执行请求
	is_requesting = true

	# 执行 HTTP 请求，传入 URL、头信息、请求方法和请求体
	var e := request(url, custom_headers, method, request_body)
	# 如果请求过程中发生错误，返回带有错误信息的 HTTPResult
	if e:
		return HTTPResult._from_error(e)

	# 忽略类型转换警告，等待请求完成信号，并将结果作为 Array 获取
	@warning_ignore('unsafe_cast')
	var result := await request_completed as Array

	# 请求完成后，将 is_requesting 设为 false
	is_requesting = false
	# 触发请求完成信号
	request_finished.emit()

	# 返回解析后的请求结果
	return HTTPResult._from_array(result)
