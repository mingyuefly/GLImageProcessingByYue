precision mediump float;
uniform sampler2D u_Texture;
varying vec2 v_TexCoordOut;
uniform float saturation;
const vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main(void) {
    vec4 color = texture2D(u_Texture, v_TexCoordOut);
    float lumiance = dot(color.rgb, W);
    vec3 grayScale = vec3(lumiance);
    gl_FragColor = vec4(mix(grayScale, color.rgb, saturation), 1.0);
    
}
