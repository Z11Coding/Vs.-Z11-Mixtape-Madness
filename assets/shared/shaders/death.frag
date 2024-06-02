    #pragma header

    uniform vec2 speed;
    uniform vec2 backdropPosition;
    uniform vec2 actualSize;

    uniform bool repeatX;
    uniform bool repeatY;

    void main(void){
        vec2 resized_PixelPos = openfl_TextureCoordv * actualSize;
        vec2 resizedPixelPos = mod(vec2(resized_PixelPos.x + backdropPosition.x, resized_PixelPos.y + backdropPosition.y), openfl_TextureSize) / openfl_TextureSize; 
        
        if (!repeatX){
            resizedPixelPos.x = resized_PixelPos.x / openfl_TextureSize.x;
        }
        if (!repeatY){
            resizedPixelPos.y = resized_PixelPos.y / openfl_TextureSize.y;
        }
        gl_FragColor = flixel_texture2D(bitmap, resizedPixelPos);

        if (resized_PixelPos.y > openfl_TextureSize.y && !repeatY){
            gl_FragColor = vec4(0.0);
        }
        if (resized_PixelPos.x > openfl_TextureSize.x && !repeatX){
            gl_FragColor = vec4(0.0);
        }
    }