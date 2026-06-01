shader_type canvas_item;

// --- Configurações de Pixelização ---
uniform float pixel_size : hint_range(1.0, 100.0, 1.0) = 8.0;
uniform float colors_per_channel : hint_range(1.0, 255.0, 1.0) = 8.0;

// --- Configurações de Visão Térmica ---
uniform bool thermal_vision = false;
// NOVO: 0 = Warm, 1 = Hot, 2 = Very Hot
uniform int heat_level : hint_range(0, 2) = 1; 

void fragment() {
    // Pixelização
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 pixel_count = tex_size / max(pixel_size, 1.0);
    vec2 pixelated_uv = floor(UV * pixel_count) / pixel_count;
    
    vec4 color = texture(TEXTURE, pixelated_uv);
    
    // Visão de Calor
    if (thermal_vision) {
        vec3 hue = normalize(color.rgb + vec3(0.0001)); 
        vec3 pure_magenta = normalize(vec3(1.0, 0.0, 1.0));
        
        if (distance(hue, pure_magenta) < 0.2 && length(color.rgb) > 0.1) {
            float heat_intensity = color.r; 
            
            float thresh_mid;
            float thresh_core;
            
            if (heat_level == 0) {
                // MORNO
                thresh_mid = 0.75;
                thresh_core = 0.95;
            } else if (heat_level == 1) {
                // QUENTE
                thresh_mid = 0.6;
                thresh_core = 0.85;
            } else {
                // MUITO QUENTE
                thresh_mid = 0.2;
                thresh_core = 0.45;
            }
            
            vec3 thermal_color;
            
            if (heat_intensity > thresh_core) {
                // Centro: Amarelo para Branco
                float t = (heat_intensity - thresh_core) / (1.0 - thresh_core);
                thermal_color = mix(vec3(1.0, 1.0, 0.0), vec3(1.0, 1.0, 1.0), t);
                
            } else if (heat_intensity > thresh_mid) {
                // Meio: Laranja para Amarelo
                float t = (heat_intensity - thresh_mid) / (thresh_core - thresh_mid);
                thermal_color = mix(vec3(1.0, 0.5, 0.0), vec3(1.0, 1.0, 0.0), t);
                
            } else {
                // Borda: Vermelho para Laranja
                float t = heat_intensity / thresh_mid;
                thermal_color = mix(vec3(1.0, 0.0, 0.0), vec3(1.0, 0.5, 0.0), t);
            }
            
            color.rgb = thermal_color;
            
        } else {
            // Frio (Cenário)
            float grayscale = dot(color.rgb, vec3(0.299, 0.587, 0.114));
            vec3 cold_dark = vec3(0.02, 0.05, 0.2);
            vec3 cold_light = vec3(0.2, 0.5, 0.8);
            color.rgb = mix(cold_dark, cold_light, grayscale);
        }
    }
    
    color.rgb = floor(color.rgb * colors_per_channel) / colors_per_channel;
    COLOR = color;
}