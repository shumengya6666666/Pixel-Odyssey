shader_type canvas_item;

// 定义渐变的起始颜色和结束颜色
uniform vec4 color_start = vec4(0.5, 0.0, 0.5, 1.0); // 紫色
uniform vec4 color_end = vec4(1.0, 0.0, 1.0, 1.0);   // 粉色

//uniform vec4 color_start = vec4(1.0, 0.0, 0.0, 1.0); // 红色
//uniform vec4 color_end = vec4(0.0, 0.0, 1.0, 1.0);   // 蓝色

//uniform vec4 color_start = vec4(0.0, 1.0, 0.0, 1.0); // 绿色
//uniform vec4 color_end = vec4(1.0, 1.0, 0.0, 1.0);   // 黄色


uniform float speed = 1.0; // 控制颜色渐变的速度

void fragment() {
    // 通过 TIME 获取时间值，并计算一个在 0 到 1 之间循环的渐变因子
    float time_factor = abs(sin(TIME * speed));

    // 在起始颜色和结束颜色之间插值，时间驱动渐变
    vec4 gradient_color = mix(color_start, color_end, time_factor);

    // 获取当前像素的纹理颜色，保留 AnimatedSprite2D 的纹理
    vec4 texture_color = texture(TEXTURE, UV);

    // 将渐变色应用到纹理颜色上，并保留纹理的细节
    COLOR = texture_color * gradient_color;
}
