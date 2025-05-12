shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform vec2 scroll_speed = vec2(0.05, 0.05);

void fragment() {
    vec2 scrolling_uv = UV + scroll_speed * TIME;
    vec4 noise_col = texture(noise, scrolling_uv);
    COLOR = noise_col;
}
