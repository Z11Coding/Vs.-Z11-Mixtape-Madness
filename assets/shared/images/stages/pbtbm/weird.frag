//from the phoenix (fms_cat)

#version 120

#define saturate(i) clamp(i,0.,1.)

varying vec2 imageCoord;
varying vec4 color;

uniform float time;
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform sampler2D sampler0;
uniform sampler2D samplerRandom;
uniform float noiseAmp = 0.0;
uniform float gain = 1.0;
uniform float offset = 0.0;

bool isValidUV( vec2 v ) { return 0.0 < v.x && v.x < 1.0 && 0.0 < v.y && v.y < 1.0; }
vec2 img2tex( vec2 v ) { return v / textureSize * imageSize * 1; }

mat2 rotate2D( float t ) {
  return mat2( cos( t ), sin( t ), -sin( t ), cos( t ));
}

void main() {
  vec2 uv = ( imageCoord - 0.5 - offset) + 0.5;
  vec3 col = vec3( 0.0 );

  #define FUCK(a,f) uv += a * noiseAmp * rotate2D( time ) * ( texture2D( samplerRandom, saturate( 0.5 + f * uv * imageSize / imageSize.y ) ).xy - 0.5 );
  FUCK( 1.0, 0.01 )
  FUCK( 0.5, 0.02 )
  FUCK( 5.25, 0.04 )
  col.x = gain * texture2D( sampler0, img2tex( uv ) ).x;
  FUCK( 12.125, 0.08 )
  col.y = gain * texture2D( sampler0, img2tex( uv ) ).y;
  FUCK( 3.0625, 0.16 )
  col.z = gain * texture2D( sampler0, img2tex( uv ) ).z;

  gl_FragColor = color * vec4( saturate( col ), 1.0 );
}
