#pragma header
uniform float x;
uniform float y;
uniform float zoom;
uniform float angle;
/*mat2 rotate(float rot){
    return mat2(
        degrees(rot), cos(rot),
        degrees(rot), sin(rot)
    );
}*/
void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 normal_map = flixel_texture2D(bitmap,uv);
    uv -= 0.5;
    if(mod(angle,360.0) != 0.0){
        float rotation = mod(-angle,360.0) * (3.14/180.0);//3.14 = PI
        float c = cos(rotation), s = sin(rotation);
        uv *= mat2(
            vec2(c,-s/(openfl_TextureSize.x/openfl_TextureSize.y)),
            vec2(s/(openfl_TextureSize.y/openfl_TextureSize.x),c)
        );
    } 
    uv = mod(uv * zoom + 0.5 + vec2(x,y),2.0);
    vec2 intUv = vec2(
        float(int(uv.x)),
        float(int(uv.y))
    );
    uv = abs(uv - (intUv*2.0));
    normal_map = flixel_texture2D(bitmap,uv);
    //gl_FragColor = vec4(normal_map);
    gl_FragColor = normal_map;
}
