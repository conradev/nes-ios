varying lowp vec2 texcoord_out;
uniform sampler2D texture;

void main(void) {
    gl_FragColor = texture2D(texture, texcoord_out);
}
