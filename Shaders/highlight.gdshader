shader_type canvas_item;

uniform sampler2D vertical_gradient; // 用于设置 alpha 值，可以使效果在某些点消失或重新出现
uniform sampler2D color_gradient; // 设置效果的颜色，支持 2D 渐变
uniform float size_effect : hint_range(-5.0, 5.0, 0.05) = 0.1; // 效果的大小
uniform float speed = 1.0; // 效果速度；如果设置为负数，效果将反向
uniform float highlight_strength : hint_range(-4.0, 4.0, 0.05) = 0.5; // 颜色覆盖基础颜色的强度
uniform bool color_mode_toggle = false; // 改变颜色渐变的应用方式，默认作用于整个纹理，如果设置为 true 则仅作用于效果
uniform bool is_horizontal = false; // 改变方向从垂直到水平
uniform float pause_duration = 0.5; // 突出显示周期之间暂停的持续时间

void fragment() {
    // 设置基础参数
    vec4 old_color = texture(TEXTURE, UV); // 使用纹理颜色替代固定的 COLOR
    float time = TIME * abs(speed); // 使用 TIME，处理正负速度
    float effect_cycle_duration = 1.0 + pause_duration; // 完整周期和暂停时间
    float mod_time = mod(time, effect_cycle_duration); // 当前时间在周期中的位置

    // 处理暂停
    float progress = mod_time / (1.0); // 归一化 mod_time 到活动效果持续时间（排除暂停）

    // 在暂停期间，确保效果固定在最后
    if (mod_time > 1.0) {
        progress = 1.0; // 在暂停期间，保持效果在最后位置
    }

    // 如果 speed 为负，反转方向
    if (speed < 0.0) {
        progress = 1.0 - progress; // 当速度为负时，反转进度
    }

    // 设置当前时间和突出效果的边界
    float current_time = mix(0.0 - size_effect, 1.0 + size_effect, progress);
    float effect_lower_bound = current_time - size_effect;
    float effect_upper_bound = current_time + size_effect;
    float position_value = (is_horizontal) ? UV.x : UV.y;

    // 使用 smoothstep 函数平滑计算效果的边界
    float effect_distance = smoothstep(effect_lower_bound, current_time, position_value) - smoothstep(current_time, effect_upper_bound, position_value);

    // 为内部渐变颜色模式计算像素在效果中的位置
    float inner_effect_position = smoothstep(effect_lower_bound, effect_upper_bound, position_value);
    vec2 color_position = (color_mode_toggle) ? vec2(UV.x, inner_effect_position) : vec2(progress, 0.0);

    // 从颜色渐变纹理中获取新的颜色
    vec4 new_color = texture(color_gradient, color_position);

    // 计算垂直渐变和 alpha 值
    new_color = mix(old_color, new_color, vec4(texture(vertical_gradient, vec2(progress, 0.0))));

    // 将颜色应用到纹理
    COLOR.rgb = mix(old_color.rgb, new_color.rgb, effect_distance * highlight_strength);
    COLOR.a = old_color.a; // 保留原始 alpha 值
}
