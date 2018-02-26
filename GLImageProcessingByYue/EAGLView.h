//
//  EAGLView.h
//  GLImageProcessingByYue
//
//  Created by Gguomingyue on 2017/11/15.
//  Copyright © 2017年 guomingyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface EAGLView : UIView

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UITabBar *tabBar;

-(void)drawView;
-(void)updateValue;
-(void)updateTabbar;

@end
