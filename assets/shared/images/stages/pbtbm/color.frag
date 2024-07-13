#version 120

varying vec4 color;
varying vec2 imageCoord;
uniform vec2 imageSize;
uniform vec2 textureSize;
uniform float opacity = 0.5;
uniform sampler2D sampler0;
uniform vec3 col2 = vec3(0,0,0.4);

//if you need extra colors uncomment these 
//and replace instances of col2 with these in the formulas

uniform vec3 col3;
//uniform vec3 col4;
//uniform vec3 col5;
//uniform vec3 col6;

//if you want to pass in a texture to blend uncomment this and line 29
//uniform sampler2D sampler1;


vec2 img2tex( vec2 v ) { return v / textureSize * imageSize; }
void main()
{
    vec2 uv = imageCoord;

	vec3 col1 = texture2D( sampler0, img2tex(uv)).rgb;
	//vec3 col2 = vec3(0,0,0.4);
	//vec3 col2 = texture2D( sampler1,  vec2( uv.x, 1.0 - uv.y)).rgb;

//BLEND MODES! Uncomment them to apply

//col1=B
//col2=A
	//Darken Blend Modes

		//Darken
		//col1 = min(col1,col2);

		//Multiply
		//col1 = col2*col1;
		
		//Color Burn
		//col1 = 1.0-(1.0-col1)/col3;

		//Linear Burn 
		//col1 = col2+col1-1;

	//Lighten Blend Modes 
		
		//Lighten
		col1 = max(col1,col2);

		//Screen
		//col1 = 1-(1-col2)*(1-col1);

		//Color Dodge
		//col1 = col1/(1.0-col2);

		//Linear Dodge (Addition)
		//col1 = col2+col1;
	
	//Cancellation Blend Modes

		//Subtract
		//col1 = col1-col2;
		
		//Divide
		//col1 = col1/col2;

	//Inversion Blend Modes

		//Exclusion
		//col1 = 0.5-2.0*(col1-0.5)*(col2-0.5);

		//Difference
		//col1 = abs(col1-col2);

	gl_FragColor = vec4( col1, opacity )*color;
}
