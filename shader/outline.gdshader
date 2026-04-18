shader_type canvas_item;

uniform bool enabled = false;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec4 result = tex;

    if (enabled) {
        float alpha = tex.a;

        if (alpha <= 0.0) {
            vec2 texel = TEXTURE_PIXEL_SIZE * outline_width;
            float max_alpha = 0.0;

            max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2( texel.x, 0.0)).a);
            max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-texel.x, 0.0)).a);
            max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0,  texel.y)).a);
            max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0, -texel.y)).a);

            max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2( texel.x,  texel.y)).a);
            max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-texel.x, -texel.y)).a);
            max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2( texel.x, -texel.y)).a);
            max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-texel.x,  texel.y)).a);

            if (max_alpha > 0.0) {
                result = outline_color;
            }
        }
    }

    COLOR = result;
}
