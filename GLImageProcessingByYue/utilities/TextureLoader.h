//
//  TextureLoader.h
//  GLImageProcessingByYue
//
//  Created by Gguomingyue on 2018/2/8.
//  Copyright © 2018年 guomingyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <UIKit/UIKit.h>

@interface TextureLoader : NSObject

+(GLuint)loadTexture:(UIImage *)image;

@end
