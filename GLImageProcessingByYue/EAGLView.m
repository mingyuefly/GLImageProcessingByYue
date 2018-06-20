//
//  EAGLView.m
//  GLImageProcessingByYue
//
//  Created by Gguomingyue on 2017/11/15.
//  Copyright © 2017年 guomingyue. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "EAGLView.h"
#import "MYShaderCompiler.h"
#import "TextureLoader.h"
#import <AVFoundation/AVFoundation.h>

@interface EAGLView ()
{
    EAGLContext *context;
    CAEAGLLayer *eaglLayer;
    
    CGRect realRect;
    
    GLuint viewRenderbuffer, viewFramebuffer;
    
    GLint width;
    GLint height;
    UIImage *processImage;
    GLuint originalTexture;
    
    MYShaderCompiler *renderShader;
    MYShaderCompiler *brightnessShader;
    MYShaderCompiler *contrastShader;
    MYShaderCompiler *saturationShader;
    MYShaderCompiler *hueShader;
    MYShaderCompiler *sharpnessShader;
    MYShaderCompiler *rgbShader;
    MYShaderCompiler *exposureShader;
    
    GLuint _renderPositionSlot;
    GLuint _renderTextureSlot;
    GLuint _renderTextureCoordSlot;
    
    GLuint filterFrameBuffer;
    GLuint filterTexture;
    
    GLuint _brightness;
    GLuint _brightnessPositionSlot;
    GLuint _brightnessTextureSlot;
    GLuint _brightnessTextureCoordSlot;
    
    GLuint _contrast;
    GLuint _contrastPositionSlot;
    GLuint _contrastTextureSlot;
    GLuint _contrastTextureCoordSlot;
    
    GLuint _saturation;
    GLuint _saturationPositionSlot;
    GLuint _saturationTextureSlot;
    GLuint _saturationTextureCoordSlot;
    
    GLuint _hueAdjust;
    GLuint _hueAdjustPositionSlot;
    GLuint _hueAdjustTextureSlot;
    GLuint _hueAdjustTextureCoordSlot;
    
    GLuint _sharpness;
    GLuint _imageWidthFactor;
    GLuint _imageHeightFactor;
    GLuint _sharpnessPositionSlot;
    GLuint _sharpnessTextureSlot;
    GLuint _sharpnessTextureCoordSlot;
    
    GLuint _exposure;
    GLuint _exposurePositionSlot;
    GLuint _exposureTextureSlot;
    GLuint _exposureTextureCoordSlot;
    
    GLuint _green;
    GLuint _red;
    GLuint _blue;
    GLuint _rgbPositionSlot;
    GLuint _rgbTextureSlot;
    GLuint _rgbTextureCoordSlot;
}
@end

@implementation EAGLView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

-(void)setupView
{
    [self setupContext];
    processImage = [UIImage imageNamed:@"Image.png"];
    originalTexture = [TextureLoader loadTexture:processImage];
    
    [self setupCAEAGLayer:self.bounds];
}

-(void)drawView
{
    [self clearRenderBuffers];
    [self createFilterFrameBuffer:processImage];
    [self setupRenderBuffers];
    [self setupViewPort];
    [self setupShader];
    [self renderToScreenWithTexture:originalTexture];
}

-(void)setupContext
{
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
}

-(void)setupCAEAGLayer:(CGRect)rect
{
    eaglLayer = [CAEAGLLayer layer];
    eaglLayer.frame = rect;
    eaglLayer.backgroundColor = [UIColor yellowColor].CGColor;
    eaglLayer.opaque = YES;
    
    eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@(NO),kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
    [self.layer addSublayer:eaglLayer];
}

-(void)createFilterFrameBuffer:(UIImage *)image
{
    glGenFramebuffers(1, &filterFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, filterFrameBuffer);
    
    // create the texture
    glGenTextures(1, &filterTexture);
    glBindTexture(GL_TEXTURE_2D, filterTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // Bind the texture to your FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, filterTexture, 0);
    
    // Test if everything failed
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        printf("failed to make complete framebuffer object %x", status);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

-(void)clearRenderBuffers
{
    if (viewRenderbuffer) {
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
    if (viewFramebuffer) {
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
}

-(void)clearFilterBuffers
{
    if (filterFrameBuffer) {
        glDeleteFramebuffers(1, &filterFrameBuffer);
        filterFrameBuffer = 0;
    }
}

-(void)setupRenderBuffers
{
    glGenFramebuffers(1, &viewFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    glGenRenderbuffers(1, &viewRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    // check success
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object: %i", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

-(void)setupViewPort
{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
}

-(void)setupShader
{
    rgbShader = [[MYShaderCompiler alloc] initWithVertexShader:@"vertexShader.vsh" fragmentShader:@"rgb_GL.fsh"];
    [rgbShader prepareToDraw];
    _rgbPositionSlot = [rgbShader attributeIndex:@"a_Position"];
    _rgbTextureSlot = [rgbShader uniformIndex:@"u_Texture"];
    _rgbTextureCoordSlot = [rgbShader attributeIndex:@"a_TexCoordIn"];
    _green = [rgbShader uniformIndex:@"redAdjustment"];
    _red = [rgbShader uniformIndex:@"greenAdjustment"];
    _blue = [rgbShader uniformIndex:@"blueAdjustment"];
    
    brightnessShader = [[MYShaderCompiler alloc] initWithVertexShader:@"vertexShader.vsh" fragmentShader:@"Brightness_GL.fsh"];
    [brightnessShader prepareToDraw];
    _brightnessPositionSlot = [brightnessShader attributeIndex:@"a_Position"];
    _brightnessTextureSlot = [brightnessShader uniformIndex:@"u_Texture"];
    _brightnessTextureCoordSlot = [brightnessShader attributeIndex:@"a_TexCoordIn"];
    _brightness = [brightnessShader uniformIndex:@"brightness"];
    
    contrastShader = [[MYShaderCompiler alloc] initWithVertexShader:@"vertexShader.vsh" fragmentShader:@"contrast_GL.fsh"];
    [contrastShader prepareToDraw];
    _contrastPositionSlot = [contrastShader attributeIndex:@"a_Position"];
    _contrastTextureSlot = [contrastShader uniformIndex:@"u_Texture"];
    _contrastTextureCoordSlot = [contrastShader attributeIndex:@"a_TexCoordIn"];
    _contrast = [contrastShader uniformIndex:@"contrast"];
    
    hueShader = [[MYShaderCompiler alloc] initWithVertexShader:@"vertexShader.vsh" fragmentShader:@"hue_GL.fsh"];
    [hueShader prepareToDraw];
    _hueAdjustPositionSlot = [hueShader attributeIndex:@"a_Position"];
    _hueAdjustTextureSlot = [hueShader uniformIndex:@"u_Texture"];
    _hueAdjustTextureCoordSlot = [hueShader attributeIndex:@"a_TexCoordIn"];
    _hueAdjust = [hueShader uniformIndex:@"hueAdjust"];
    
    exposureShader = [[MYShaderCompiler alloc] initWithVertexShader:@"vertexShader.vsh" fragmentShader:@"exposure_GL.fsh"];
    [exposureShader prepareToDraw];
    _exposurePositionSlot = [exposureShader attributeIndex:@"a_Position"];
    _exposureTextureSlot = [exposureShader uniformIndex:@"u_Texture"];
    _exposureTextureCoordSlot = [exposureShader attributeIndex:@"a_TexCoordIn"];
    _exposure = [exposureShader uniformIndex:@"exposure"];
    
    saturationShader = [[MYShaderCompiler alloc] initWithVertexShader:@"vertexShader.vsh" fragmentShader:@"saturation_GL.fsh"];
    [saturationShader prepareToDraw];
    _saturationPositionSlot = [saturationShader attributeIndex:@"a_Position"];
    _saturationTextureSlot = [saturationShader uniformIndex:@"u_Texture"];
    _saturationTextureCoordSlot = [saturationShader attributeIndex:@"a_TexCoordIn"];
    _saturation = [saturationShader uniformIndex:@"saturation"];
    
    sharpnessShader = [[MYShaderCompiler alloc] initWithVertexShader:@"sharpenessVertexShader.vsh" fragmentShader:@"sharpness_GL.fsh"];
    [sharpnessShader prepareToDraw];
    _sharpnessPositionSlot = [sharpnessShader attributeIndex:@"a_Position"];
    _sharpnessTextureSlot = [sharpnessShader uniformIndex:@"u_Texture"];
    _sharpnessTextureCoordSlot = [sharpnessShader attributeIndex:@"a_TexCoordIn"];
    _sharpness = [sharpnessShader uniformIndex:@"sharpness"];
    _imageWidthFactor = [sharpnessShader uniformIndex:@"imageWidthFactor"];
    _imageHeightFactor = [sharpnessShader uniformIndex:@"imageHeightFactor"];
    
    renderShader = [[MYShaderCompiler alloc] initWithVertexShader:@"vertexShader.vsh" fragmentShader:@"fragmentShader.fsh"];
    [renderShader prepareToDraw];
    _renderPositionSlot = [renderShader attributeIndex:@"a_Position"];
    _renderTextureSlot = [renderShader uniformIndex:@"u_Texture"];
    _renderTextureCoordSlot = [renderShader attributeIndex:@"a_TexCoordIn"];
}

-(void)renderToScreenWithTexture:(GLint)texture
{
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    [self setupViewPort];
    [renderShader prepareToDraw];
    
    UIImage *image = processImage;
    CGRect realRect = AVMakeRectWithAspectRatioInsideRect(image.size, self.bounds);
    CGFloat widthRatio = realRect.size.width/self.bounds.size.width;
    CGFloat heightRatio = realRect.size.height/self.bounds.size.height;
    
    const GLfloat vertices[] = {
        -widthRatio, -heightRatio, 0,  //左下
        widthRatio, -heightRatio, 0,   //右下
        -widthRatio, heightRatio, 0,   //左上
        widthRatio, heightRatio, 0     //右上
    };
    glEnableVertexAttribArray(_renderPositionSlot);
    glVertexAttribPointer(_renderPositionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    
    // normal
    static const GLfloat coords[] = {
        0, 0,
        1, 0,
        0, 1,
        1, 1
    };
    glEnableVertexAttribArray(_renderTextureCoordSlot);
    glVertexAttribPointer(_renderTextureCoordSlot, 2, GL_FLOAT, GL_FALSE, 0, coords);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(_renderTextureSlot, 5);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawRawImageWithPositionSlot:(GLuint)positionSlot TextureCoordSlot:(GLuint)textureCoordSlot {
    // 传递顶点数据
    const GLfloat vertices[] = {
        -1, -1, 0,   //左下
        1,  -1, 0,   //右下
        -1, 1,  0,   //左上
        1,  1,  0 }; //右上
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    
    // normal
    static const GLfloat coords[] = {
        0, 0,
        1, 0,
        0, 1,
        1, 1
    };
    glEnableVertexAttribArray(textureCoordSlot);
    glVertexAttribPointer(textureCoordSlot, 2, GL_FLOAT, GL_FALSE, 0, coords);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(void)updateValue
{
    NSInteger mode = self.tabBar.selectedItem.tag;
    float value = self.slider.value;
    
    // 让OpengGL绑定滤镜frameBuffer
    glBindFramebuffer(GL_FRAMEBUFFER, filterFrameBuffer);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, (GLsizei)processImage.size.width, (GLsizei)processImage.size.height);
    switch (mode) {
        case 0:
        {
            // 使用亮度shader
            [brightnessShader prepareToDraw];
            // 传递调节亮度的值区间（-1， 1）
            glUniform1f(_brightness, value);
            
            glActiveTexture(GL_TEXTURE5);
            glBindTexture(GL_TEXTURE_2D, originalTexture);
            glUniform1i(_brightnessTextureSlot, 5);
            
            [self drawRawImageWithPositionSlot:_brightnessPositionSlot TextureCoordSlot:_brightnessTextureCoordSlot];
        }
            break;
        case 1:
        {
            // 使用对比度shader
            [contrastShader prepareToDraw];
            // 传递调节对比度的值区间（0.0， 4.0）
            glUniform1f(_contrast, value);
            
            glActiveTexture(GL_TEXTURE5);
            glBindTexture(GL_TEXTURE_2D, originalTexture);
            glUniform1i(_contrastTextureSlot, 5);
            
            [self drawRawImageWithPositionSlot:_contrastPositionSlot TextureCoordSlot:_contrastTextureCoordSlot];
        }
            break;
        case 2:
        {
            // 使用饱和度shader
            [saturationShader prepareToDraw];
            // 传递调节饱和度的值区间（0， 2）
            glUniform1f(_saturation, value);
            
            glActiveTexture(GL_TEXTURE5);
            glBindTexture(GL_TEXTURE_2D, originalTexture);
            glUniform1i(_saturationTextureSlot, 5);
            
            [self drawRawImageWithPositionSlot:_saturationPositionSlot TextureCoordSlot:_saturationTextureCoordSlot];
            
            // 使用rgb的shader
//            [rgbShader prepareToDraw];
//            // 传递RGB值区间
//            glUniform1f(_green, value);
//            glUniform1f(_red, 1.0f);
//            glUniform1f(_blue, 1.0f);
//
//            glActiveTexture(GL_TEXTURE5);
//            glBindTexture(GL_TEXTURE_2D, originalTexture);
//            glUniform1i(_rgbTextureSlot, 5);
//
//            [self drawRawImageWithPositionSlot:_rgbPositionSlot TextureCoordSlot:_rgbTextureCoordSlot];
        }
            break;
        case 3:
        {
            // 使用色彩度shader
            [hueShader prepareToDraw];
            CGFloat hue = fmodf(value, 360.0) * M_PI/180;
            glUniform1f(_hueAdjust, hue);
            
            glActiveTexture(GL_TEXTURE5);
            glBindTexture(GL_TEXTURE_2D, originalTexture);
            glUniform1i(_hueAdjustTextureSlot, 5);
            
            [self drawRawImageWithPositionSlot:_hueAdjustPositionSlot TextureCoordSlot:_hueAdjustTextureCoordSlot];
        }
            break;
        case 4:
        {
            // 使用锐利度shader
            [sharpnessShader prepareToDraw];
            glUniform1f(_imageWidthFactor, 1.0 / 320);
            glUniform1f(_imageHeightFactor, 1.0 / 240);
            glUniform1f(_sharpness, value);
            
            glActiveTexture(GL_TEXTURE5);
            glBindTexture(GL_TEXTURE_2D, originalTexture);
            glUniform1i(_sharpnessTextureSlot, 5);
            
            [self drawRawImageWithPositionSlot:_sharpnessPositionSlot TextureCoordSlot:_sharpnessTextureCoordSlot];
            
            // 使用曝光度shader
//            [exposureShader prepareToDraw];
//            glUniform1f(_exposure, value);
//
//            glActiveTexture(GL_TEXTURE5);
//            glBindTexture(GL_TEXTURE_2D, originalTexture);
//            glUniform1i(_exposureTextureSlot, 5);
//
//            [self drawRawImageWithPositionSlot:_exposurePositionSlot TextureCoordSlot:_exposureTextureCoordSlot];
        }
            break;
        default:
            break;
    }
    
    [self renderToScreenWithTexture:filterTexture];
}

-(void)updateTabbar
{
    NSInteger mode = self.tabBar.selectedItem.tag;
    switch (mode) {
        case 0:
        {
            [self.slider setMaximumValue:1.0f];
            [self.slider setValue:0.0f];
            [self.slider setMinimumValue:-1.0f];
        }
            break;
        case 1:
        {
            [self.slider setMaximumValue:4.0f];
            [self.slider setValue:1.0f];
            [self.slider setMinimumValue:0.0f];
        }
            break;
        case 2:
        {
            [self.slider setMaximumValue:4.0f];
            [self.slider setValue:1.0f];
            [self.slider setMinimumValue:0.0f];
        }
            break;
        case 3:
        {
            [self.slider setMaximumValue:360.0f];
            [self.slider setValue:90.0f];
            [self.slider setMinimumValue:0.0f];
        }
            break;
        case 4:
        {
            [self.slider setMaximumValue:4.0f];
            [self.slider setValue:0.0f];
            [self.slider setMinimumValue:-1.0f];
        }
            break;
        default:
            break;
    }
    
    [self updateValue];
}

@end
