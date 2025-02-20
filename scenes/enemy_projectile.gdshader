shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.0;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);
    vec4 glow = glow_color * glow_intensity;
    COLOR = mix(current_color, glow, 0.5);
}