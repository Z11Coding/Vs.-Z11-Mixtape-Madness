#pragma header
uniform float zoom;
uniform float angle;
uniform vec2 offset;
uniform bool mirrorX;
uniform bool mirrorY;

void main(){
    // https://www.shadertoy.com/view/tsSXzt helped
    vec2 fragCoord = openfl_TextureCoordv.xy * openfl_TextureSize.xy;
    vec2 uv = ( fragCoord - .5*openfl_TextureSize.xy ) / openfl_TextureSize.y;

    float rads = radians(angle);
    mat2 rotationMatrix = mat2(
        cos(rads), sin(rads),
        -sin(rads), cos(rads) );

    mat2 fixRotation = mat2(  // the aspect ratio get squished bercause of the above code ^, this just unsquishes it
        0.5625, 0.0,
        0.0, 1.0
    );

    uv /= zoom;
    uv *= rotationMatrix;
    uv *= fixRotation;
    uv += 0.5;

    uv += offset * vec2(0.00078125, 0.00138888);
    if(mirrorX){
        if ((uv.x > 1.0 || uv.x < 0.0) && abs(mod(uv.x, 2.0)) > 1.0)
            uv.x = (0.0-uv.x)+1.0;
    }
    if(mirrorY){
        if ((uv.y > 1.0 || uv.y < 0.0) && abs(mod(uv.y, 2.0)) > 1.0)
            uv.y = (0.0-uv.y)+1.0;
    }

    gl_FragColor = flixel_texture2D(bitmap, vec2(abs(mod(uv.x, 1.0)), abs(mod(uv.y, 1.0))));