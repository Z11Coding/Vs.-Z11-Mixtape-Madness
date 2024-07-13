// from analys by fms_cat

#version 120

#define PI 3.14159265
#define SAMPLES 20
#define saturate(i) clamp(i,0.,1.)

// ------

varying vec2 imageCoord;
varying vec4 color;

uniform vec2 textureSize;
uniform vec2 imageSize;

uniform bool isVert;
uniform float var = 0.0;

uniform sampler2D sampler0;

// ------

float gaussian( float _x, float _v ) {
  return 1.0 / sqrt( 2.0 * PI * _v ) * exp( - _x * _x / 2.0 / _v );
}

// ------

bool isValidUV( vec2 v ) { return 0.0 < v.x && v.x < 1.0 && 0.0 < v.y && v.y < 1.0; }
vec2 img2tex( vec2 v ) { return v / textureSize * imageSize; }

void main() {
  vec2 uv = imageCoord;
  vec2 bv = ( isVert ? vec2( 0.0, 1.0 ) : vec2( 1.0, 0.0 ) ) / imageSize;

  
  vec3 sum = vec3( 0.0 );
  for ( int i = -SAMPLES; i <= SAMPLES; i ++ ) {
    vec2 v = saturate( uv + bv * float( i * 2 ) );
    vec3 tex = texture2D( sampler0, img2tex( v ) ).xyz;
    float mul = saturate( gaussian( abs( float( i ) ), var ) );
    sum += tex * mul;
  }

  gl_FragColor = vec4( sum, 1.0 )*color;
}