shader_type canvas_item;

// Pre-calculated constants for the purple color
uniform vec4 color_to_remove = vec4(0.0, 1.0, 1.0, 1.0); // Normalized RGB for RGB(195, 134, 255)
uniform float threshold = 0.1; // You can adjust this value in the Godot Inspector

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (distance(tex_color.rgb, color_to_remove.rgb) < threshold) {
        discard;
    }
    COLOR = tex_color;
}
