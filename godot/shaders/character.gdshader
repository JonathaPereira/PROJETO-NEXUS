shader_type canvas_item;
uniform float bend = 0.0;
uniform float sprite_height = 244.0;
uniform float flash = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0);
varying vec4 item_tint;
void vertex() {
    item_tint = COLOR;
    float height_factor = 1.0 - clamp(VERTEX.y / sprite_height, 0.0, 1.0);
    VERTEX.x += bend * height_factor * height_factor;
}
void fragment() {
    vec4 sampled = texture(TEXTURE, UV);
    float silhouette = smoothstep(0.08, 0.78, sampled.a);
    vec3 lit = mix(sampled.rgb, flash_color.rgb, flash * 0.65);
    COLOR = vec4(lit, silhouette) * item_tint;
}
