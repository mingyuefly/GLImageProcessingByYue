//
//  MYShaderCompiler.h
//  openGLESRealize
//
//  Created by Gguomingyue on 2017/11/14.
//  Copyright © 2017年 Gguomingyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface MYShaderCompiler : NSObject

-(instancetype)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;
-(void)prepareToDraw;
-(GLuint)uniformIndex:(NSString *)uniformName;
-(GLuint)attributeIndex:(NSString *)attributeName;

@end
