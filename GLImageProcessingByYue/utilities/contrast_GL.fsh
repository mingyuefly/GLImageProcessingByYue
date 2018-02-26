precision mediump float;
varying vec2 v_TexCoordOut;

uniform sampler2D u_Texture;
uniform float contrast;

void main()
{
    vec4 textureColor = texture2D(u_Texture, v_TexCoordOut);
    
    gl_FragColor = vec4(((textureColor.rgb - vec3(0.5)) * contrast + vec3(0.5)), textureColor.w);
}
