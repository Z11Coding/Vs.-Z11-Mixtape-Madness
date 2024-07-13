// taken from s bahn
// adapted from https://www.shadertoy.com/view/Wts3DB

#version 130

uniform float alpha = 1;
uniform float time;

varying vec4 color;
varying vec2 imageCoord;
varying vec2 textureCoord;
uniform vec2 resolution;
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform sampler2D sampler0;
out vec4 fragColor;

uniform vec3 colmult = vec3(1,1,1);
uniform float sizemult = 0;

#define COUNT 20.
#define COL_BLACK vec3(0.,0.,0.) / 255.0 

#define SF 1./min(resolution.x,resolution.y)
#define SS(l,s) smoothstep(SF,-SF,l-s)
#define hue(h) clamp( abs( fract(h + vec4(3,2,1,0)/3.) * 6. - 3.) -1. , 0., 1.)

// Original noise code from https://www.shadertoy.com/view/4sc3z2
#define MOD3 vec3(.1031,.11369,.13787)

vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * MOD3);
    p3 += dot(p3, p3.yxz+19.19);
    return -1.0 + 2.0 * fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

float simplex_noise(vec3 p)
{
    const float K1 = 0.333333333;
    const float K2 = 0.166666667;
    
    vec3 i = floor(p + (p.x + p.y + p.z) * K1);
    vec3 d0 = p - (i - (i.x + i.y + i.z) * K2);
        
    vec3 e = step(vec3(0.0), d0 - d0.yzx);
	vec3 i1 = e * (1.0 - e.zxy);
	vec3 i2 = 1.0 - e.zxy * (1.0 - e);
    
    vec3 d1 = d0 - (i1 - 1.0 * K2);
    vec3 d2 = d0 - (i2 - 2.0 * K2);
    vec3 d3 = d0 - (1.0 - 3.0 * K2);
    
    vec4 h = max(0.6 - vec4(dot(d0, d0), dot(d1, d1), dot(d2, d2), dot(d3, d3)), 0.0);
    vec4 n = h * h * h * h * vec4(dot(d0, hash33(i)), dot(d1, hash33(i + i1)), dot(d2, hash33(i + i2)), dot(d3, hash33(i + 1.0)));
    
    return dot(vec4(31.316), n);
}


void main() {
	vec4 cur = texture2D( sampler0, textureCoord);
   vec2 uv = imageCoord;
	
	float m = 0.;
	float t = time *.5;
	vec3 col;
	float malpha;
	for(float i=COUNT; i>=0.; i-=1.){
		float edge = simplex_noise(vec3(uv * vec2(2., 0.) + vec2(0, t + i*.15), 1.))*.2 + (.5/COUNT)*i + .25;
		float mi = SS(edge, uv.y) - SS(edge + .02*sizemult, uv.y);        
		m *= SS(edge, uv.y+.015);
		m += mi;        
		
		if(mi > 0.){
			col = vec3(i/COUNT);
			malpha = i;
		}        
	}           

	col *= colmult;
	
	//col = mix(COL_BLACK, col, m);
	
	fragColor = mix( vec4(1,1,1,0), vec4(1,1,1, malpha), m )*vec4(colmult, 1);
}