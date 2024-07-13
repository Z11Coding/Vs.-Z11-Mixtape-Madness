#version 120
#define PI 3.14159265

// ------

varying vec2 imageCoord;
varying vec4 color;

uniform vec2 textureSize;
uniform vec2 imageSize;

uniform float reflectionY = 0.4;

uniform sampler2D sampler0;
uniform float time;

// ------

vec2 img2tex( vec2 v ) { return v / textureSize * imageSize; }

// ------

void main() {
    vec2 uv = imageCoord;  

    vec4 waterColor = vec4(1.0);
    //vec4 reflect = vec4(0,0,0,1);
    //float reflectionY = 0.4;
    if (uv.y <= reflectionY) {        
        float oy = uv.y;
        //uv.y = 2.0*reflectionY - uv.y;
        
        uv.x = uv.x + cos(1./(oy-reflectionY)+time)*0.01;
        //uv.x = uv.x - cos(16./(oy-reflectionY+0.25)+time*5.0)*0.015;

        //uv.x = uv.x - ((uv.x-0.5)*0.2) * (1.0-oy/reflectionY);

        float ydis = sin(32./(oy-reflectionY)+time*1.0);
        uv.y += ydis*0.02;

        //vec4 add = vec4(100.0,100.0,100.0,0.0);
        waterColor = vec4(0.7, 0.85, 1.0, 1.0);

        //uv.y += sin(uv.x+time)*0.02;

        //reflect += clamp(ydis,0,1);

        uv.x /= 1.1;
        uv.x += 0.05;
    }    

    //uv.x = clamp(uv.x, 0, 1);

    vec4 col = texture2D(sampler0, img2tex(uv));

    gl_FragColor = col*color; 
}