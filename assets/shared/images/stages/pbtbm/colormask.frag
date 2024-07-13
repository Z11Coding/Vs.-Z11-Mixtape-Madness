#version 120
#define PI 3.14159265

// ------

varying vec2 imageCoord;

uniform vec2 textureSize;
uniform vec2 imageSize;

uniform sampler2D sampler0;

uniform sampler2D samplerRed;
uniform sampler2D samplerGreen;
uniform sampler2D samplerBlue;
uniform sampler2D samplerMask;

// ------

vec2 img2tex( vec2 v ) { return v / textureSize * imageSize; }

// ------

void main() {
    vec2 uv = imageCoord;  
    
    vec4 origtex = texture2D(sampler0, img2tex(uv));
    vec4 redtex = texture2D(samplerRed, img2tex(uv));
    vec4 greentex = texture2D(samplerGreen, img2tex(uv));
    vec4 bluetex = texture2D(samplerBlue, img2tex(uv));
    vec4 masktex = texture2D(samplerMask, img2tex(uv));

    vec4 col = vec4(0,0,0,1);

    col = origtex;
    
    if (masktex.r > 0) col = vec4(redtex.rgb, masktex.r);
    if (masktex.g > 0) col = vec4(greentex.rgb, masktex.g);
    if (masktex.b > 0) col = vec4(bluetex.rgb, masktex.b);

    gl_FragColor = col; 
}