shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, vertex_lighting;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform float border_multiplier: hint_range(0.0, 10.0) = 2.0;

uniform float pixel_size : hint_range(1.0, 32.0, 1.0) = 8.0; 

void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
        vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
        MODEL_MATRIX[3]
    );
    
    MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
        vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
        vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
        vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

void fragment() {
    vec2 tex_size = vec2(textureSize(sprite_texture, 0));
    vec2 texel_size = 1.0 / tex_size;
    
    vec2 pixel_count = tex_size / max(pixel_size, 1.0);
    
    vec2 pixelated_uv = floor(UV * pixel_count) / pixel_count;
    
    float alpha_sum = 0.0;
    float total_weights = 0.0;
    
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            alpha_sum += texture(sprite_texture, pixelated_uv + vec2(x, y) * texel_size * border_multiplier).a;
            total_weights += 1.0;
        }
    }
    
    float alpha_blur = alpha_sum / total_weights;
    
    ALBEDO = vec3(1.0, 0.0, 1.0) * alpha_blur;
    ALPHA = alpha_blur;
    
    if (ALPHA < 0.5) {
        discard;
    } else {
        ALPHA = 1.0;
    }
}