//
//  NESVideo.m
//  NES
//
//  Created by Conrad Kramer on 5/30/15.
//  Copyright (c) 2015 Kramer Software Productions, LLC. All rights reserved.
//

#import "NESAvailability.h"

#import <Foundation/Foundation.h>

#if METAL_ENABLED
#import <Metal/Metal.h>
#endif
#if OPENGL_ENABLED
#import <OpenGLES/gltypes.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#endif

#import "NESEmulator.h"

#include "video.h"

extern NESEmulator *emulator;

static u8 *nesscreen = NULL;
static u32 *screen = NULL;

static u8 palette[8][64 * 3];
static u32 palette32[8][256];
static u8 palettecache[32];
static u32 palettecache32[256];

#if METAL_ENABLED
static id<MTLCommandQueue> commandQueue = nil;
static id<MTLRenderPipelineState> pipelineState = nil;
static id<MTLBuffer> vertexBuffer = nil;
static id<MTLBuffer> screenBuffer = nil;
static id<MTLTexture> screenTexture = nil;
#endif

#if OPENGL_ENABLED
static EAGLContext *context = nil;
static GLuint positionSlot = 0;
static GLuint texcoordSlot = 0;
static GLuint textureUniform = 0;
static GLuint glVertexBuffer = 0;
static GLuint glScreenTexture = 0;
static GLuint framebuffer;
static GLuint renderbuffer;
#endif

typedef struct gl_vertex {
    float position[3];
    float texcoord[2];
} gl_vertex;

int video_init() {
    nesscreen = malloc(256 * 240);
    screen = malloc(256 * 240 * 4);
    
#if METAL_ENABLED || OPENGL_ENABLED
    CALayer *layer = emulator.layer;
#endif
    
#if METAL_ENABLED
    CAMetalLayer *metalLayer = ([layer isKindOfClass:[CAMetalLayer class]] ? (CAMetalLayer *)layer : nil);
    if (metalLayer) {
        NSError *error = nil;
        
        NSString *libraryPath = [[NSBundle bundleForClass:[NESEmulator class]] pathForResource:@"default" ofType:@"metallib"];
        id<MTLLibrary> library = [metalLayer.device newLibraryWithFile:libraryPath error:&error];
        
        MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
        pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"nes_vertex"];
        pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"nes_fragment"];
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:video_getwidth() height:video_getheight() mipmapped:NO];
        
        float vertices[] = {
            -1.0, -1.0,
            -1.0, 1.0,
            1.0, -1.0,
            1.0, 1.0
        };
        
        pipelineState = [metalLayer.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
        commandQueue = [metalLayer.device newCommandQueue];
        vertexBuffer = [metalLayer.device newBufferWithBytes:&vertices length:sizeof(vertices) options:MTLResourceOptionCPUCacheModeDefault];
        screenBuffer = [metalLayer.device newBufferWithBytesNoCopy:screen length:(256 * 240 * 4) options:MTLResourceOptionCPUCacheModeDefault deallocator:nil];
        screenTexture = [screenBuffer newTextureWithDescriptor:textureDescriptor offset:0 bytesPerRow:(textureDescriptor.width * 4)];
        
        if (error) {
            NSLog(@"%@: Error initializing pipeline state: %@", NSStringFromClass([NESEmulator class]), error.localizedDescription);
        }
        
        return (error != nil);
    }
#endif
    
#if OPENGL_ENABLED
    CAEAGLLayer *eaglLayer = ([layer isKindOfClass:[CAEAGLLayer class]] ? (CAEAGLLayer *)layer : nil);
    if (eaglLayer) {
        __block NSError *error = nil;
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (![EAGLContext setCurrentContext:context]) {
            NSLog(@"%@: Error setting current context", NSStringFromClass([NESEmulator class]));
            return 1;
        }
        
        eaglLayer.bounds = (CGRect){CGPointZero, CGSizeMake(video_getwidth(), video_getheight())};
        
        glGenRenderbuffers(1, &renderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
//        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        
        glGenFramebuffers(1, &framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
//        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        
        GLuint (^compile)(NSString *, GLenum) = ^(NSString *name, GLenum type) {
            NSString *path = [[NSBundle bundleForClass:[NESEmulator class]] pathForResource:name ofType:@"glsl"];
            NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            if (!string) {
                NSLog(@"%@: Error loading shader \"%@\": %@", NSStringFromClass([NESEmulator class]), name, error.localizedDescription);
                return (GLuint)0;
            }
            
            GLuint handle = glCreateShader(type);
            
            const GLchar *program = [string UTF8String];
            const GLint length = (GLint)string.length;
            glShaderSource(handle, 1, &program, &length);
            glCompileShader(handle);
            
            GLint success;
            glGetShaderiv(handle, GL_COMPILE_STATUS, &success);
            if (success == GL_FALSE) {
                GLchar messages[256];
                glGetShaderInfoLog(handle, sizeof(messages), 0, messages);
                NSLog(@"%@: %@", NSStringFromClass([NESEmulator class]), @(messages));
                return (GLuint)0;
            }
            
            return handle;
        };

        GLuint vertexShader = compile(@"NESVertex", GL_VERTEX_SHADER);
        GLuint fragmentShader = compile(@"NESFragment", GL_FRAGMENT_SHADER);
        if (vertexShader == 0 || fragmentShader == 0)
            return 1;
        
        GLuint program = glCreateProgram();
        glAttachShader(program, vertexShader);
        glAttachShader(program, fragmentShader);
        glLinkProgram(program);
        
        GLint success;
        glGetProgramiv(program, GL_LINK_STATUS, &success);
        if (success == GL_FALSE) {
            GLchar messages[256];
            glGetProgramInfoLog(program, sizeof(messages), 0, messages);
            NSLog(@"%@: %@", NSStringFromClass([NESEmulator class]), @(messages));
            return 1;
        }
        
        glUseProgram(program);
        
        positionSlot = glGetAttribLocation(program, "position");
        texcoordSlot = glGetAttribLocation(program, "texcoord_in");
        glEnableVertexAttribArray(positionSlot);
        glEnableVertexAttribArray(texcoordSlot);
        
        textureUniform = glGetUniformLocation(program, "texture");
        
        const gl_vertex vertices[] = {
            {{-1, -1, 0}, {0, 0}},
            {{1, -1, 0}, {1, 0}},
            {{-1, 1, 0}, {0, 1}},
            {{1, 1, 0}, {1, 1}}
        };
        glGenBuffers(1, &glVertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, glVertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        glGenTextures(1, &glScreenTexture);
        glBindTexture(GL_TEXTURE_2D, glScreenTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        [EAGLContext setCurrentContext:nil];
        
        return (error != nil);
    }
#endif
    
    return 0;
}

void video_kill() {
#if METAL_ENABLED
    if (commandQueue) {
        commandQueue = nil;
        pipelineState = nil;
        vertexBuffer = nil;
        screenBuffer = nil;
        screenTexture = nil;
    }
#endif
    
#if OPENGL_ENABLED
    if (context) {
        [EAGLContext setCurrentContext:context];
        glDeleteTextures(1, &glScreenTexture);
        glDeleteBuffers(1, &glVertexBuffer);
        positionSlot = 0;
        texcoordSlot = 0;
        textureUniform = 0;
        [EAGLContext setCurrentContext:nil];
        context = nil;
    }
#endif
    
    if (screen)
        free(screen);
    if (nesscreen)
        free(nesscreen);
    screen = NULL;
    nesscreen = NULL;
}

int video_reinit() {
    video_kill();
    return video_init();
}

void video_startframe() {
    
}

#if METAL_ENABLED
void video_metal_endframe() {
    CAMetalLayer *metalLayer = (CAMetalLayer *)emulator.layer;
    metalLayer.drawableSize = CGSizeApplyAffineTransform(metalLayer.bounds.size, CGAffineTransformMakeScale(metalLayer.contentsScale, metalLayer.contentsScale));
    
    if (CGSizeEqualToSize(metalLayer.drawableSize, CGSizeZero)) {
        NSLog(@"%@: The drawable's size is empty", emulator);
        return;
    }
    
    id<CAMetalDrawable> drawable = [metalLayer nextDrawable];
    if (!drawable) {
        NSLog(@"%@: The drawable cannot be nil", emulator);
        return;
    }
    
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor new];
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [commandEncoder setRenderPipelineState:pipelineState];
    [commandEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [commandEncoder setFragmentTexture:screenTexture atIndex:0];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4 instanceCount:1];
    [commandEncoder endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}
#endif

#if OPENGL_ENABLED
void video_eagl_endframe() {
    if (![EAGLContext setCurrentContext:context])
        return;
    
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);

    CGRect bounds = emulator.layer.bounds;
    glViewport(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds), CGRectGetHeight(bounds));
    
    glBindBuffer(GL_ARRAY_BUFFER, glVertexBuffer);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(gl_vertex), 0);
    glVertexAttribPointer(texcoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(gl_vertex), (GLvoid *)(sizeof(float) * 3));
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, glScreenTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, video_getwidth(), video_getheight(), 0, GL_BGRA, GL_UNSIGNED_BYTE, screen);
    glUniform1i(textureUniform, 0);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    [EAGLContext setCurrentContext:nil];
}
#endif

void video_quartz_endframe() {
    CALayer *layer = emulator.layer;
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, screen, 256 * 240 * 4, NULL);
    layer.contents = (__bridge_transfer id)CGImageCreate(video_getwidth(), video_getheight(), 8, video_getbpp(), 4 * video_getwidth(), space, kCGBitmapByteOrderDefault, provider, NULL, false, 0);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(space);
}

void video_endframe() {
    dispatch_sync(dispatch_get_main_queue(), ^{
        CALayer *layer = emulator.layer;
        
#if METAL_ENABLED
        CAMetalLayer *metalLayer = ([layer isKindOfClass:[CAMetalLayer class]] ? (CAMetalLayer *)layer : nil);
        if (metalLayer)
            return video_metal_endframe();
#endif
        
#if OPENGL_ENABLED
        CAEAGLLayer *eaglLayer = ([layer isKindOfClass:[CAEAGLLayer class]] ? (CAEAGLLayer *)layer : nil);
        if (eaglLayer)
            return video_eagl_endframe();
#endif
        
        if (layer)
            return video_quartz_endframe();
    });

}

void video_updatepixel(int line,int pixel,u8 s) {
    int offset = (line * 256) + pixel;
    nesscreen[offset] = s;
    screen[offset] = palettecache32[s];
}

void video_updatepalette(u8 addr,u8 data) {
    palettecache32[addr+0x00] = palette32[0][data];
    palettecache32[addr+0x20] = palette32[1][data];
    palettecache32[addr+0x40] = palette32[2][data];
    palettecache32[addr+0x60] = palette32[3][data];
    palettecache32[addr+0x80] = palette32[4][data];
    palettecache32[addr+0xA0] = palette32[5][data];
    palettecache32[addr+0xC0] = palette32[6][data];
    palettecache32[addr+0xE0] = palette32[7][data];
    palettecache[addr] = data;
}

void video_setpalette(palette_t *p) {
    for (int j = 0; j < 8 ; j++) {
        for (int i = 0; i < 64; i++) {
            palette[j][(i * 3) + 0] = p->pal[j][i].r;
            palette[j][(i * 3) + 1] = p->pal[j][i].g;
            palette[j][(i * 3) + 2] = p->pal[j][i].b;
        }
    }
    
    for (int j = 0; j < 8; j++) {
        for (int i = 0; i < 256; i++) {
            palentry_t *entry = &p->pal[j][i & 0x3F];
            palette32[j][i] = (entry->r << 0) | (entry->g << 8) | (entry->b << 16);
        }
    }
}

int video_getwidth() {
    return 256;
}

int video_getheight() {
    return 240;
}

int video_getbpp() {
    return 32;
}

u8 *video_getscreen() {
    return nesscreen;
}

u8 *video_getpalette() {
    return (u8 *)palette;
}

int video_zapperhit(int x,int y) {
    return 0;
}
