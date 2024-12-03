// 定义这是一个用于 canvas_item 的着色器
shader_type canvas_item;

// 颜色变量，用于控制雨滴的颜色，默认为灰色 (0.5, 0.5, 0.5)
uniform vec3 color: source_color = vec3(0.5);

// 控制雨滴下落速度的变量，范围从 0.01 到 10，默认值为 0.1
uniform float speed: hint_range(0.01, 10.0, 0.01) = 0.1;

// 控制雨滴之间密度的变量，范围从 1 到 500，默认值为 100
uniform float density: hint_range(1.0, 500.0, 1.0) = 100.0;

// 控制雨滴压缩（细长效果）的变量，范围从 0.1 到 1.0，默认值为 0.2
uniform float compression: hint_range(0.1, 1.0, 0.01) = 0.2;

// 控制雨滴拖尾大小的变量，范围从 5.0 到 100.0，默认值为 50.0
uniform float trail_size: hint_range(5.0, 100.0, 0.1) = 50.0;

// 控制雨滴亮度的变量，范围从 0.1 到 10.0，默认值为 5.0
uniform float brightness: hint_range(0.1, 10.0, 0.1) = 5.0;

void fragment() {
    // 获取当前片段的 UV 坐标，并翻转 Y 轴
    vec2 uv = -UV;
    
    // 根据 TIME 变量和 speed，计算动画时间
    float time = TIME * speed;

    // 将 X 轴方向的 UV 坐标乘以密度，增大雨滴的重复效果
    uv.x *= density;

    // 计算 duv，使用 floor 函数确保 UV 取整，同时在 Y 方向乘以 compression 实现压缩效果
    vec2 duv = vec2(floor(uv.x), uv.y) * compression;

    // 根据 duv 的 X 值生成一个偏移量，用于产生雨滴的波动效果
    float offset = sin(duv.x);

    // 计算 cos 函数产生的衰减效果，控制雨滴的落下速度变化
    float fall = cos(duv.x * 30.0);

    // 混合拖尾大小和 100，使用 fall 控制拖尾效果
    float trail = mix(100.0, trail_size, fall);

    // 计算雨滴的位置偏移和时间变化，fract 函数保证值在 [0, 1] 范围内
    float drop = fract(duv.y + time * fall + offset) * trail;

    // 对 drop 取倒数，增强雨滴的形状效果
    drop = 1.0 / drop;

    // 使用 smoothstep 函数对 drop 值进行平滑处理，增强视觉效果
    drop = smoothstep(0.0, 1.0, drop * drop);

    // 使用 sin 函数结合 PI，进一步对 drop 的效果进行波动处理，控制亮度
    drop = sin(drop * PI) * fall * brightness;

    // 计算雨滴形状的 X 轴变化，使用 fract 和 sin 函数生成平滑的雨滴形状
    float shape = sin(fract(uv.x) * PI);

    // 根据形状乘以亮度变化，增强雨滴效果
    drop *= shape * shape;

    // 最终输出颜色，将 drop 乘以颜色，并将 alpha 值设置为 0.0 使背景透明
    COLOR = vec4(color * drop, drop);
}
