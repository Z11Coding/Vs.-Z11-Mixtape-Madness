#version 120
#define PI 3.14159265

// ------

varying vec2 imageCoord;

uniform vec2 textureSize;
uniform vec2 imageSize;

uniform sampler2D sampler0;

uniform sampler2D samplerGreen;
uniform sampler2D samplerMask;

// ------

vec2 img2tex( vec2 v ) { return v / textureSize * imageSize; }

// ------

void main() {
    vec2 uv = imageCoord;  
    
    vec4 greentex = texture2D(samplerGreen, img2tex(uv));
    vec4 masktex = texture2D(samplerMask, img2tex(uv));

    gl_FragColor = vec4(greentex.rgb, masktex.g); 
}