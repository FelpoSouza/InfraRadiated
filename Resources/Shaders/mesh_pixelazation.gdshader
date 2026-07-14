shader_type spatial;
render_mode depth_draw_opaque;

uniform sampler2D albedo_texture : source_color, filter_nearest;

uniform float pixel_density : hint_range(1.0, 512.0) = 256.0;
uniform float pixel_aspect_ratio : hint_range(0.1, 10.0, 0.01) = 0.25;

void fragment() {
    vec2 density = vec2(pixel_density, pixel_density * pixel_aspect_ratio);

    vec2 pixelated_uv = floor(UV * density) / density;
    
    vec4 tex_color = texture(albedo_texture, pixelated_uv);
    
    ALBEDO = tex_color.rgb;
    
    ALPHA = tex_color.a;
    ALPHA_SCISSOR_THRESHOLD = 0.5; 
}