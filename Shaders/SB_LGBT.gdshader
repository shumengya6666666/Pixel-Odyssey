shader_type canvas_item;

uniform float speed = 0.3;  // 控制彩虹变化的速度
uniform float intensity = 0.5;  // 控制彩虹颜色的强度，让颜色更淡
uniform float color_mix_factor = 1.0;  // 控制彩虹色与原色的混合程度 (0.0 - 1.0)

// 函数：通过时间生成平滑的 RGB 颜色渐变
vec3 smooth_rainbow(float t) {
    float r = 0.5 + 0.5 * sin(6.28318 * t + 0.0);  // 红色分量，使用 sin 函数平滑变化
    float g = 0.5 + 0.5 * sin(6.28318 * t + 2.0944);  // 绿色分量，相位偏移 2π/3
    float b = 0.5 + 0.5 * sin(6.28318 * t + 4.18879);  // 蓝色分量，相位偏移 4π/3
    return vec3(r, g, b);
}

void fragment() {
    // 获取当前像素的纹理颜色
    vec4 texture_color = texture(TEXTURE, UV);

    // 生成平滑的彩虹颜色，t 基于时间和 UV.x 坐标
    float t = UV.x + abs(sin(TIME * speed));
    vec3 rainbow_color = smooth_rainbow(t);
    
    // 将彩虹颜色变淡，控制强度
    rainbow_color = mix(vec3(1.0), rainbow_color, intensity);

    // 混合彩虹颜色与原始纹理颜色，color_mix_factor 控制混合比例
    vec3 final_color = mix(texture_color.rgb, rainbow_color, color_mix_factor);

    // 最终颜色输出，保留原来的透明度
    COLOR = vec4(final_color, texture_color.a);
}
