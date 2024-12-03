// 声明这是一个用于 canvas_item 的着色器
shader_type canvas_item;

// Color A: 默认设置为灰色，用户可以调整这个值
uniform vec4 color_a:source_color = vec4(0.7, 0.7, 0.7, 1.0);

// Color B: 默认设置为白色，用户可以调整这个值
uniform vec4 color_b:source_color = vec4(1.0, 1.0, 1.0, 1.0);

// 如果启用此选项，color_a 和 color_b 的 alpha 值将影响最终的透明度
uniform bool colors_affect_alpha = false;

// 控制动画效果的启动或关闭，当 flash_amount 大于 0 时，颜色在 color_a 和 color_b 之间变化
uniform float flash_amount:hint_range(0.0, 1.0, 0.1) = 1.0;

// 控制闪烁的速度，决定 color_a 和 color_b 之间切换的快慢
uniform float flash_speed = 1.0;

// 控制整个着色器的透明度，与 modulate 类似
uniform float transparency:hint_range(0.0, 1.0, 0.01) = 1.0;

// 着色器的强度，决定效果的可见度
uniform float intensity:hint_range(0.0, 1.0, 0.1) = 1.0;

// anim 函数通过 sin 函数创建一个基于时间的动画效果
// sin 函数返回在 [-1, 1] 之间的值，通过加 1 再除以 2 将其范围变为 [0, 1]
float anim() {
    return (sin(TIME * flash_speed) + 1.0) / 2.0;
}

// 该函数根据 anim() 的结果在 color_a 和 color_b 之间进行混合，返回一个颜色值
vec4 get_shader_color() {
    // 如果 flash_amount 大于 0，意味着启用了动画效果
    if (flash_amount > 0.0) {
        // 通过 anim() 获取动画的变化量 f
        float f = anim();
        // 根据 f 和 flash_amount 的值混合 color_a 和 color_b，返回一个混合的颜色
        return mix(color_a, color_b, f * flash_amount);
    } else {
        // 如果 flash_amount 为 0，直接返回 color_a 作为颜色
        return color_a;
    }
}

// fragment 函数负责计算每个像素的颜色
void fragment() {
    // 从纹理中获取当前 UV 坐标对应的输入颜色
    vec4 in_color = texture(TEXTURE, UV);
    // 获取输入颜色的 alpha 值（透明度）
    float in_alpha = in_color.a;

    // 调用 get_shader_color() 函数获取在 color_a 和 color_b 之间混合的颜色
    vec4 shader_rgba = get_shader_color();
    // 提取 shader_rgba 中的 RGB 颜色分量
    vec3 shader_color = shader_rgba.rgb;
    // 提取 shader_rgba 中的 alpha 分量
    float shader_alpha = shader_rgba.a;

    // 将输入颜色和混合后的 shader_color 按照 shader_alpha 值进行混合
    // 这样 color_a 和 color_b 可以拥有不同的“强度”
    vec4 out_color = vec4(mix(in_color.rgb, shader_color, shader_alpha), in_alpha);

    // 如果 colors_affect_alpha 为 true，将根据 color_a 和 color_b 的 alpha 值影响最终透明度
    if (colors_affect_alpha) {
        // 根据 flash_amount 混合输入的 alpha 值和混合颜色的 alpha 值
        out_color.a = mix(in_alpha, shader_alpha, flash_amount);
    }

    // 根据 uniform 中的 transparency 值调节最终颜色的 alpha 值
    out_color.a *= transparency;

    // 最后根据 intensity 值调节整体效果的强度
    COLOR = mix(in_color, out_color, intensity);
}
