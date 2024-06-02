// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

uniform float iTime;

void main()
{
	vec2 iResolution = openfl_TextureSize;
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec4 tex = flixel_texture2D(bitmap, uv);
    vec3 greyScale = vec3(.5, .5, .5);
    gl_FragColor = vec4( vec3(dot( tex.rgb, greyScale)), flixel_texture2D(bitmap, uv).a);

}