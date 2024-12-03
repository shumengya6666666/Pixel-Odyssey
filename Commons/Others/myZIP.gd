# ===========================
# myZIP
# 基于ZIPPacker和ZIPReader封装的ZIP压缩包创建和读取辅助函数库
# Godot 4.0.3.stable.official [5222a99f5]
# 巽星石
# 2023年6月15日21:54:26
# 2023年6月15日21:54:53
# ===========================
class_name myZIP

# =========================== 读取ZIP ===========================
# 读取ZIP
static func read_zip(zip_path:String, call_back:Callable):
	var zip_reader := ZIPReader.new()
	var err := zip_reader.open(zip_path)
	if err != OK:
		return err
	call_back.call(zip_reader)
	zip_reader.close()

# 从ZIP压缩包中读取并返回JPG图片
static func get_zip_image(zip_reader:ZIPReader, file_name:String) -> ImageTexture:
	var img_bytes = zip_reader.read_file(file_name)
	var img = Image.new()
	var ext = file_name.get_extension()
	if ext in ["jpg", "png", "bmp", "tga", "webp"]:
		img.call("load_%s_from_buffer" % ext, img_bytes)
	else:
		return
	return ImageTexture.create_from_image(img)

# 返回ZIP压缩包中指定名称的纯文本文件的文本内容
static func get_file_txt(zip_reader:ZIPReader, file_name:String) -> String:
	var txt_bytes = zip_reader.read_file(file_name)
	return txt_bytes.get_string_from_utf8()

# 返回ZIP压缩包中指定名称的二进制文件的字节数组内容
static func get_file_bytes(zip_reader:ZIPReader, file_name:String) -> PackedByteArray:
	var txt_bytes = zip_reader.read_file(file_name)
	return txt_bytes

# =========================== 创建ZIP ===========================
static func create_zip(zip_path:String, call_back:Callable):
	var zip_packer := ZIPPacker.new()
	var err := zip_packer.open(zip_path, ZIPPacker.APPEND_CREATE)
	if err != OK:
		return err
	call_back.call(zip_packer)
	zip_packer.close_file()
	zip_packer.close()
	return OK

# 在zip中添加已经存在的纯文本文件
static func put_txt_file(zip_packer:ZIPPacker, file_name:String, file_path:String):
	zip_packer.start_file(file_name)
	var file_content = get_txt_file_string(file_path)
	zip_packer.write_file(file_content.to_utf8_buffer())

# 在zip中添加已经存在的二进制文件
static func put_binary_file(zip_packer:ZIPPacker, file_name:String, file_path:String):
	zip_packer.start_file(file_name)
	var file_content = get_binary_file_bytes(file_path)
	zip_packer.write_file(file_content)

# 在zip中写入纯文本文件
static func write_txt_file(zip_packer:ZIPPacker, file_name:String, file_content:String):
	zip_packer.start_file(file_name)
	zip_packer.write_file(file_content.to_utf8_buffer())

# 在zip中写入二进制文件
static func write_binary_file(zip_packer:ZIPPacker, file_name:String, file_content:PackedByteArray):
	zip_packer.start_file(file_name)
	zip_packer.write_file(file_content)

# =========================== 辅助函数 ===========================
# 返回文件的二进制字节数组形式
static func get_binary_file_bytes(file_path:String):
	return FileAccess.get_file_as_bytes(file_path)

# 返回纯文本文件的字符串内容
static func get_txt_file_string(file_path:String):
	return FileAccess.get_file_as_string(file_path)
