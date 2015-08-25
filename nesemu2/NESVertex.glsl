attribute vec4 position;
attribute vec2 texcoord_in;

varying vec2 texcoord_out;

void main(void) { 
    gl_Position = position;
    texcoord_out = texcoord_in;
}
