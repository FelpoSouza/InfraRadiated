shader_type canvas_item;

// We no longer need hint_screen_texture! 
// Godot automatically passes the Viewport's image into a built-in sampler named 'TEXTURE'

uniform float pixel_size : hint_range(1.0, 100.0, 1.0) = 8.0;
uniform float colors_per_channel : hint_range(1.0, 255.0, 1.0) = 8.0;

void fragment() {
    // 1. Get the size of the internal viewport texture
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 pixel_count = tex_size / max(pixel_size, 1.0);
    
    // 2. Use UV (the container's internal coordinates) instead of SCREEN_UV
    vec2 pixelated_uv = floor(UV * pixel_count) / pixel_count;
    
    // 3. Sample the actual 3D viewport image data
    vec4 color = texture(TEXTURE, pixelated_uv);
    
    // 4. Color crush
    color.rgb = floor(color.rgb * colors_per_channel) / colors_per_channel;
    
    COLOR = color;
}