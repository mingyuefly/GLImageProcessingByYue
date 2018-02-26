attribute vec4 a_Position;

attribute vec2 a_TexCoordIn;
varying vec2 v_TexCoordOut;
varying vec4 a_position_out;

attribute vec4 inputTextureCoordinate;

uniform float imageWidthFactor;
uniform float imageHeightFactor;
uniform float sharpness;

varying vec2 textureCoordinate;
varying vec2 leftTextureCoordinate;
varying vec2 rightTextureCoordinate;
varying vec2 topTextureCoordinate;
varying vec2 bottomTextureCoordinate;

varying float centerMultiplier;
varying float edgeMultiplier;

void main()
{
    gl_Position = a_Position;
    v_TexCoordOut = a_TexCoordIn;
    a_position_out = a_Position;
    
    vec2 widthStep = vec2(imageWidthFactor, 0.0);
    vec2 heightStep = vec2(0.0, imageHeightFactor);
    
    textureCoordinate = inputTextureCoordinate.xy;
    leftTextureCoordinate = inputTextureCoordinate.xy - widthStep;
    rightTextureCoordinate = inputTextureCoordinate.xy + widthStep;
    topTextureCoordinate = inputTextureCoordinate.xy + heightStep;
    bottomTextureCoordinate = inputTextureCoordinate.xy - heightStep;
    
    centerMultiplier = 1.0 + 4.0 * sharpness;
    edgeMultiplier = sharpness;
}
