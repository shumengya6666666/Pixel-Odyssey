// 定义这是一个用于 canvas_item 的着色器
shader_type canvas_item;

// 控制每个融化像素条的锯齿感，也就是波的振幅
uniform float meltness: hint_range(0.0, 3.0) = 1.0;

// 控制是否只影响着色器的底部部分，同时也会增加融化程度
uniform float how_low: hint_range(0.0, 5.0) = 1.0;

// 控制波的频率（波动的密集度）
uniform float wave_frequency: hint_range(0.0, 30.0) = 20.0;

uniform float speed: hint_range(0.0, 30.0) = 10.0;

// 定义波的函数，基于 x 计算波形
float wave(float x, float time_progress) {
    // x 减去 2.5 后，再加上基于时间和频率的波动
	return x - 2.5 + cos(2.0 * PI * time_progress + wave_frequency * x);
}

void fragment() {
    // 获取当前片段的 UV 坐标
	vec2 uv = UV;
    
    // 使用 TIME 来动态控制 progress，使其随着时间不断变化
    float time_progress = mod(TIME * speed, 1.0);  // 乘以 0.2 来调节动画速度

    // 将 Y 轴上的 UV 坐标减去一个基于 Y 值的波动偏移量
	// 使用 `pow` 函数使 `how_low` 控制效果的下沉程度
	// `meltness` 控制波的振幅，`wave` 函数控制波形的变化
	uv.y -= pow(uv.y, how_low) * 0.02 * meltness * wave(UV.x - mod(UV.x, TEXTURE_PIXEL_SIZE.x), time_progress);
	
    // 根据修改后的 UV 坐标从纹理中获取颜色
	COLOR = texture(TEXTURE, uv);
	
    // "删除"超出范围的像素，将 Y 坐标超出 0.0 或 1.0 的像素设置为透明
	if (uv.y <= 0.0 || uv.y >= 1.0) {
		COLOR.a = 0.0;
	}
}
