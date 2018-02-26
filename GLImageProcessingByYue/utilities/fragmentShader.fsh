precision mediump float;
uniform sampler2D u_Texture;
varying vec2 v_TexCoordOut;

varying vec4 vDestinationColor;

void main(void) {
    vec4 color = texture2D(u_Texture, v_TexCoordOut);
    gl_FragColor = color;
}

