extends Node

#整数 (int)
@export var int_number: int = 5
#浮点数 (float)
@export var float_number: float = 5.0
#布尔值 (bool)
@export var is_active: bool = true
#字符串 (String)
@export var string: String = ""

##2. 枚举 (Enum) 导出

#使用内置或自定义枚举类型导出：
enum Direction { LEFT, RIGHT, UP, DOWN }
@export var direction: Direction = Direction.LEFT

##3. 资源类型导出

#图像 (Image)
@export var image: Image
#自定义资源 (CustomResource)
@export var custom_resource: Resource

##4. 节点 (Node) 类型导出

#节点 (Node)
@export var node: Node
#自定义节点 (CustomNode)
@export var custom_node: Node

##5. 数组类型导出

#整数数组 (Array[int])
@export var int_array: Array[int]
#节点数组 (Array[Node])
@export var node_array: Array[Node]

#@export 相关的高级注解

#Godot 4.2 中还提供了多种注解来进一步定制导出变量的行为：
#1. @export_category(name: String)

#为导出变量定义一个新类别，方便在检查器面板中组织属性。
@export_category("Statistics")
@export var hp: int = 30
@export var speed: float = 1.25

#2. @export_color_no_alpha

#导出一个不允许编辑透明度的颜色属性。
@export_color_no_alpha var dye_color: Color

#3. @export_dir

#将 String 属性作为目录路径导出。
@export_dir var sprite_folder_path: String

#4. @export_enum(names: String, ...)

#将 int 或 String 属性导出为枚举选项列表。
@export_enum("Warrior", "Magician", "Thief") var character_class: int

#5. @export_file(filter: String = "", ...)

#将 String 属性导出为文件路径，并可以通过 filter 限制文件类型。
@export_file("*.txt") var notes_file: String

#6. @export_flags(names: String, ...)

#将整数属性导出为位标志字段，用于表示多个选项的组合。
@export_flags("Fire", "Water", "Earth", "Wind") var spell_elements: int

#7. @export_range(min: float, max: float, step: float = 1.0, extra_hints: String = "", ...)

#将 int 或 float 属性导出为具有范围的值，可以设置最小值、最大值、步长等。
@export_range(0, 100, 1, "or_greater") var power_percent: int
