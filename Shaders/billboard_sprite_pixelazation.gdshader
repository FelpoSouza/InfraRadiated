shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, vertex_lighting;

uniform sampler2D sprite_texture : source_color, filter_nearest;

uniform float pixel_size : hint_range(1.0, 32.0, 1.0) = 8.0; 

void vertex() {
    float scale_x = length(MODEL_MATRIX[0].xyz);
    float scale_y = length(MODEL_MATRIX[1].xyz);
    float scale_z = length(MODEL_MATRIX[2].xyz);
    
    MODELVIEW_MATRIX[0].xyz = vec3(scale_x, 0.0, 0.0);
    MODELVIEW_MATRIX[1].xyz = vec3(0.0, scale_y, 0.0);
    MODELVIEW_MATRIX[2].xyz = vec3(0.0, 0.0, scale_z);
    
    MODELVIEW_MATRIX = VIEW_MATRIX * MODEL_MATRIX;
    
    MODELVIEW_MATRIX[0].xyz = vec3(scale_x, 0.0, 0.0);
    MODELVIEW_MATRIX[2].xyz = vec3(0.0, 0.0, scale_z);
}

void fragment() {
    vec2 tex_size = vec2(textureSize(sprite_texture, 0));
    
    vec2 pixel_count = tex_size / max(pixel_size, 1.0);
    
    vec2 pixelated_uv = floor(UV * pixel_count) / pixel_count;
    
    vec4 tex_color = texture(sprite_texture, pixelated_uv);
    
    ALBEDO = tex_color.rgb;
    ALPHA = tex_color.a;
    
    if (ALPHA < 0.1) {
        discard;
    }
}