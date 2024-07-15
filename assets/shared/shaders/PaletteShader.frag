#pragma header
uniform float stretch;
uniform float size;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 normal_map = flixel_texture2D(bitmap,uv);
    //gl_FragColor = vec4(normal_map);
    gl_FragColor = normal_map;
}
