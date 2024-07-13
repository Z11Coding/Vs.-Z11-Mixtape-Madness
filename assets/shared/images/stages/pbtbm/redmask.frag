#version 120
#define PI 3.14159265

// ------

varying vec2 imageCoord;

uniform vec2 textureSize;
uniform vec2 imageSize;

uniform sampler2D sampler0;

uniform sampler2D samplerRed;
uniform sampler2D samplerMask;

// ------

vec2 img2tex( vec2 v ) { return v / textureSize * imageSize; }

// ------

void main() {
    vec2 uv = imageCoord;  
    
    vec4 redtex = texture2D(samplerRed, img2tex(uv));
    vec4 masktex = texture2D(samplerMask, img2tex(uv));

    gl_FragColor = vec4(redtex.rgb, masktex.r); 
}