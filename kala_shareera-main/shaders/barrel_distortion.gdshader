shader_type canvas_item;

uniform float distortion_strength : hint_range(0.0, 0.5) = 0.1;
uniform vec2 lens_center = vec2(0.5, 0.5);

void fragment() {
    vec2 uv = UV - lens_center;
    float r2 = dot(uv, uv);
    float distortion = 1.0 + distortion_strength * r2;
    vec2 distorted_uv = lens_center + uv * distortion;
    
    if (distorted_uv.x < 0.0 || distorted_uv.x > 1.0 || 
        distorted_uv.y < 0.0 || distorted_uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        COLOR = texture(TEXTURE, distorted_uv);
    }
}
