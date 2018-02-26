precision mediump float;
varying vec2 v_TexCoordOut;

uniform sampler2D u_Texture;
uniform float redAdjustment;
uniform float greenAdjustment;
uniform float blueAdjustment;

void main()
{
    vec4 textureColor = texture2D(u_Texture, v_TexCoordOut);
    
    gl_FragColor = vec4(textureColor.r * redAdjustment, textureColor.g * greenAdjustment, textureColor.b * blueAdjustment, textureColor.a);
}

