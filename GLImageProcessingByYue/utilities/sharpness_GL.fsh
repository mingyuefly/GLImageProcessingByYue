precision mediump float;
uniform sampler2D u_Texture;
varying vec2 v_TexCoordOut;

varying vec2 leftTextureCoordinate;
varying vec2 rightTextureCoordinate;
varying vec2 topTextureCoordinate;
varying vec2 bottomTextureCoordinate;

varying float centerMultiplier;
varying float edgeMultiplier;

void main()
{
    vec3 textureColor = texture2D(u_Texture, v_TexCoordOut).rgb;
    vec3 leftTextureColor = texture2D(u_Texture, leftTextureCoordinate).rgb;
    vec3 rightTextureColor = texture2D(u_Texture, rightTextureCoordinate).rgb;
    vec3 topTextureColor = texture2D(u_Texture, topTextureCoordinate).rgb;
    vec3 bottomTextureColor = texture2D(u_Texture, bottomTextureCoordinate).rgb;
    
    gl_FragColor = vec4((textureColor * centerMultiplier - (leftTextureColor * edgeMultiplier + rightTextureColor * edgeMultiplier + topTextureColor * edgeMultiplier + bottomTextureColor * edgeMultiplier)), texture2D(u_Texture, bottomTextureCoordinate).w);
}
