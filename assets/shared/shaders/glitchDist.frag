// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define round(a) floor(a + 0.5)
#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
#define texture flixel_texture2D

// third argument fix
vec4 flixel_texture2D(sampler2D bitmap, vec2 coord, float bias) {
	vec4 color = texture2D(bitmap, coord, bias);
	if (!hasTransform)
	{
		return color;
	}
	if (color.a == 0.0)
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	if (!hasColorTransform)
	{
		return color * openfl_Alphav;
	}
	color = vec4(color.rgb / color.a, color.a);
	mat4 colorMultiplier = mat4(0);
	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
	colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
	color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
	if (color.a > 0.0)
	{
		return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
	}
	return vec4(0.0, 0.0, 0.0, 0.0);
}

// variables which is empty, they need just to avoid crashing shader
uniform float iTimeDelta;
uniform float iFrameRate;
uniform int iFrame;
#define iChannelTime float[4](iTime, 0., 0., 0.)
#define iChannelResolution vec3[4](iResolution, vec3(0.), vec3(0.), vec3(0.))
uniform vec4 iMouse;
uniform vec4 iDate;



float rand(float n){return fract(sin(n) * 43758.5453123);}

float noise(float p){
	float fl = floor(p);
    float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}

float blockyNoise(vec2 uv, float threshold, float scale, float seed)
{
	float scroll = floor(iTime + sin(11.0 *  iTime) + sin(iTime) ) * 0.77;
    vec2 noiseUV = uv.yy / scale + scroll;
    float noise2 = texture(iChannel1, noiseUV).r;
    
    float id = floor( noise2 * 20.0);
    id = noise(id + seed) - 0.5;
    
  
    if ( abs(id) > threshold )
        id = 0.0;

	return id;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    float rgbIntesnsity = 0.1 + 0.1 * sin(iTime* 3.7);
    float displaceIntesnsity = 0.2 +  0.3 * pow( sin(iTime * 1.2), 5.0);
    float interlaceIntesnsity = 0.01;
    float dropoutIntensity = 0.1;

    
    vec2 uv = fragCoord/iResolution.xy;

	float displace = blockyNoise(uv + vec2(uv.y, 0.0), displaceIntesnsity, 25.0, 66.6);
    displace *= blockyNoise(uv.yx + vec2(0.0, uv.x), displaceIntesnsity, 111.0, 13.7);
    
    uv.x += displace ;
    
    vec2 offs = 0.1 * vec2(blockyNoise(uv.xy + vec2(uv.y, 0.0), rgbIntesnsity, 65.0, 341.0), 0.0);
    
    float colr = texture(iChannel0, uv-offs).r;
	float colg = texture(iChannel0, uv).g;
    float colb = texture(iChannel0, uv +offs).b;

    
    float line = fract(fragCoord.y / 3.0);
	vec3 mask = vec3(3.0, 0.0, 0.0);
		if (line > 0.333)
			mask = vec3(0.0, 3.0, 0.0);
		if (line > 0.666)
			mask = vec3(0.0, 0.0, 3.0);
    
    
	float maskNoise = blockyNoise(uv, interlaceIntesnsity, 90.0, iTime) * max(displace, offs.x);
    
    maskNoise = 1.0 - maskNoise;
    if ( maskNoise == 1.0)
        mask = vec3(1.0);
    
    float dropout = blockyNoise(uv, dropoutIntensity, 11.0, iTime) * blockyNoise(uv.yx, dropoutIntensity, 90.0, iTime);
    mask *= (1.0 - 5.0 * dropout);
	
    
    fragColor = vec4(mask * vec3(colr, colg, colb), texture(iChannel0, uv).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}