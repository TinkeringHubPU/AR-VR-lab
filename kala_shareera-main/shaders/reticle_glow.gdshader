shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = tex + glow_color * glow_intensity * tex.a;
}
