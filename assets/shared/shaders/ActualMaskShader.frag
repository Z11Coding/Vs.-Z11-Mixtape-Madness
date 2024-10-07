#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

uniform sampler2D iChannel1;

void mainImage()
{
    // uniforms
    vec4 tex_color = texture(bitmap, uv);
    vec4 tex2_color = texture(iChannel1, uv);

    float texColorSum = tex_color.r + tex_color.g + tex_color.b;

   // i have no idea why this works but I'll go with it
    if (tex2_color.a == 0){
        tex_color.rgb = vec3(0.0, 0.0, 0.0);
        tex_color.a = 0;
    }
  
    gl_FragColor = tex_color;
}