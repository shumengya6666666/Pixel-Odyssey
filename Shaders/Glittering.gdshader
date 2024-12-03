shader_type canvas_item;

uniform bool gold_effect_enabled = true; // 开关，控制金光效果的启用
uniform float speed = 2.0; // 控制闪烁速度
uniform float edge_thickness = 1.0; // 边缘厚度
uniform vec4 gold_color = vec4(1.0, 0.85, 0.0, 1.0); // 金色镶边
uniform float blur_amount = 0.5; // 模糊强度
uniform bool is_hit = false; // 开关，控制角色是否被攻击时变红
uniform float hit_intensity = 1.0; // 控制变红的强度

// 高斯模糊权重
vec4 blur(sampler2D tex, vec2 uv) {
    vec4 sum = vec4(0.0);
    float blur_size = blur_amount / 100.0;

    sum += texture(tex, uv + vec2(-blur_size, -blur_size)) * 0.0625;
    sum += texture(tex, uv + vec2( blur_size, -blur_size)) * 0.0625;
    sum += texture(tex, uv + vec2(-blur_size,  blur_size)) * 0.0625;
    sum += texture(tex, uv + vec2( blur_size,  blur_size)) * 0.0625;

    sum += texture(tex, uv + vec2(-blur_size, 0.0)) * 0.125;
    sum += texture(tex, uv + vec2( blur_size, 0.0)) * 0.125;
    sum += texture(tex, uv + vec2(0.0, -blur_size)) * 0.125;
    sum += texture(tex, uv + vec2(0.0,  blur_size)) * 0.125;

    sum += texture(tex, uv) * 0.25;

    return sum;
}

void fragment() {
    // 获取当前像素的纹理颜色和透明度
    vec4 texture_color = texture(TEXTURE, UV);
    float alpha = texture_color.a;

    // 处理被攻击时的变红效果
    if (is_hit && alpha > 0.0) {
        // 混合红色效果，根据 hit_intensity 控制强度
        vec4 red_tint = vec4(1.0, 0.0, 0.0, 1.0); // 红色
        texture_color = mix(texture_color, red_tint, hit_intensity);
    }

    // 只在效果开启时启用金光效果
    if (gold_effect_enabled && alpha > 0.0) {
        // 基于 alpha 通道计算边缘
        float edge_factor = smoothstep(0.0, edge_thickness, alpha) * (1.0 - alpha);

        // 生成金色镶边
        vec4 edge_color = gold_color * edge_factor;

        // 实现高斯模糊的效果
        vec4 blurred_texture = blur(TEXTURE, UV);

        // 计算时间驱动的闪烁效果
        float glow_factor = abs(sin(TIME * speed));
        vec4 glow_color = gold_color * glow_factor;

        // 最终颜色组合，包含纹理、金色镶边、模糊和闪烁效果
        COLOR = mix(texture_color, blurred_texture + edge_color + glow_color, 0.5);
    } else {
        // 如果是透明区域或者效果关闭，保持原始颜色
        COLOR = texture_color;
    }
}
