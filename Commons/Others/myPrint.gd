# ========================================================
# 名称：myPrint
# 类型：静态函数库
# 简介：基于print_rich()封装的富文本打印相关函数
# 作者：巽星石
# Godot版本：v4.2.2.stable.official [15073afe3]
# 创建时间：2024年4月18日17:58:41
# 最后修改时间：2024年4月19日00:33:20
# ========================================================

class_name myPrint

# 定义颜色枚举
enum MyColor { BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, PINK, PURPLE, CYAN, WHITE, ORANGE, GRAY }

# 对齐方式
enum Align { LEFT, CENTER, RIGHT }

# 定义常量以便在代码中使用
const GRAY = MyColor.GRAY
const LEFT = Align.LEFT

# 获取对应索引的颜色字符串
static func get_color(idx: int) -> String:
	var cols = ["black", "red", "green", "yellow", "blue", "magenta", "pink", "purple", "cyan", "white", "orange", "gray"]
	return cols[idx]

# 获取对应索引的位置字符串
static func get_pos(idx: int) -> String:
	var positions = ["left", "center", "right"]
	return positions[idx]

# 获取对应url的链接
static func link(url: String) -> String:
	return "[url]%s[/url]" % url

static func print(
	content: String,         # 打印内容
	color: int = GRAY,       # 字色
	bg_color: int = -1,      # 背景色
	pos: int = LEFT,         # 打印位置
	bold: bool = false,      # 粗体
	italic: bool = false,    # 斜体
	underline: bool = false, # 下划线
	strikethrough: bool = false # 删除线
) -> void:
	# ----------- 粗体、斜体、下划线、删除线 -----------
	if bold:
		content = "[b]%s[/b]" % content
	if italic:
		content = "[i]%s[/i]" % content
	if underline:
		content = "[u]%s[/u]" % content
	if strikethrough:
		content = "[s]%s[/s]" % content

	# ----------- 字色和背景色 -----------
	if color:
		content = "[color=%s]%s[/color]" % [get_color(color), content]
	if bg_color > 0:
		content = "[bgcolor=%s]%s[/bgcolor]" % [get_color(bg_color), content]

	# ----------- 对齐方式 -----------
	if pos != LEFT:
		content = "[%s]%s[/%s]" % [get_pos(pos), content, get_pos(pos)]

	print_rich("%s" % content)
