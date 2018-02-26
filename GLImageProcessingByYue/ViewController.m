//
//  ViewController.m
//  GLImageProcessingByYue
//
//  Created by Gguomingyue on 2017/11/15.
//  Copyright © 2017年 guomingyue. All rights reserved.
//

#import "ViewController.h"
#import "EAGLView.h"

#define DEG2RAD (M_PI/180.0f)

// These enums match the button tags in the nib
enum {
    BUTTON_BRIGHTNESS,
    BUTTON_CONTRAST,
    BUTTON_SATURATION,
    BUTTON_HUE,
    BUTTON_SHARPNESS,
    NUM_BUTTONS
};


@interface ViewController ()<UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UISlider *slider;
- (IBAction)sliderAction:(UISlider *)sender;
@property (nonatomic, strong) EAGLView *eaglView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.delegate = self;
    
    self.eaglView = [[EAGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.eaglView];
    [self updateTabbar];
    [self.eaglView drawView];
    
    [self.view bringSubviewToFront:self.slider];
    [self.view bringSubviewToFront:self.tabBar];
    self.eaglView.slider = self.slider;
    self.eaglView.tabBar = self.tabBar;
}

-(void)updateTabbar
{
    int b, i;
    
    // Select first tab by default
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    
    // Creat a bitmap context for rendering the tabbar buttons
    // Usually, button images are loaded from disk, but these simple shapes can be procedurally generatd
    // UITabBar only needs the alpha channel of these images.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(nil, 30, 30, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGImageRef theCGImage;
    
    // Draw with white round strokes
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextSetLineWidth(context, 2.0f);
    
    for (b = 0; b < NUM_BUTTONS; b++) {
        CGContextClearRect(context, CGRectMake(0, 0, 30, 30));
        switch (b) {
            case BUTTON_BRIGHTNESS:
            {
                const CGFloat line[8*4] = {
                    15.0, 6.0, 15.0, 4.0,
                    15.0,24.0, 15.0,26.0,
                    6.0,15.0,  4.0,15.0,
                    24.0,15.0, 26.0,15.0,
                    21.5,21.5, 23.0,23.0,
                    8.5, 8.5,  7.0, 7.0,
                    21.5, 8.5, 23.0, 7.0,
                    8.5,21.5,  7.0,23.0,
                };
                
                // A circle with eight rays around it
                CGContextStrokeEllipseInRect(context, CGRectMake(10.5, 10.5, 9.0, 9.0));
                for (i = 0; i < 8; i++) {
                    CGContextMoveToPoint(context, line[i*4+0], line[i*4+1]);
                    CGContextAddLineToPoint(context, line[i*4+2], line[i*4+3]);
                    CGContextStrokePath(context);
                }
            }
                break;
            case BUTTON_CONTRAST:
            {
                // A circle with the right half filled
                CGContextStrokeEllipseInRect(context, CGRectMake(4.0, 4.0, 22.0, 22.0));
                CGContextAddArc(context, 15.0f, 15.0f, 11.0f, -M_PI/2.0, M_PI/2.0, false);
                CGContextFillPath(context);
            }
                break;
            case BUTTON_SATURATION:
            {
                CGGradientRef gradient;
                const CGFloat strip[3][12] = {
                    { 0.3,0.3,0.3,0.15, 1.0,0.0,0.0,0.70,  5, 5, 7, 25 },
                    { 0.5,0.5,0.5,0.25, 0.0,1.0,0.0,0.75, 12, 5, 6, 25 },
                    { 0.2,0.2,0.2,0.10, 0.0,0.0,1.0,0.65, 18, 5, 7, 25 }
                };
                // Red/Green/Blue gradients, inside a rounded rect
                for (i = 0; i < 3; i++) {
                    gradient = CGGradientCreateWithColorComponents(colorSpace, strip[i], NULL, 2);
                    CGContextSaveGState(context);
                    CGContextClipToRect(context, CGRectMake(strip[i][8], strip[i][9], strip[i][10], strip[i][11]));
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(15, 5), CGPointMake(15, 25), 0);
                    CGContextRestoreGState(context);
                    CGGradientRelease(gradient);
                }
                CGContextMoveToPoint(context, 4, 15);
                CGContextAddArcToPoint(context, 4, 4, 15, 4, 4);
                CGContextAddArcToPoint(context, 26, 4, 26, 15, 4);
                CGContextAddArcToPoint(context, 26, 26, 15, 26, 4);
                CGContextAddArcToPoint(context, 4, 26, 4, 15, 4);
                CGContextClosePath(context);
                CGContextStrokePath(context);
            }
                break;
            case BUTTON_HUE:
            {
                CGGradientRef gradient;
                CGFloat hue[8];
                const int angle = 4;
                
                // A radial gradient, inside a circle
                for (i = 0; i < 360; i+=angle)
                {
                    float x = cosf((i+angle*0.5)*DEG2RAD)*10+15;
                    float y = sinf((i+angle*0.5)*DEG2RAD)*10+15;
                    float r = (i    )/180.0; if (r > 1.0) r = 2.0-r;
                    float g = (i+120)/180.0; if (g > 2.0) g = g-2.0; else if (g > 1.0) g = 2.0-g;
                    float b = (i+240)/180.0; if (b > 3.0) b = 4.0-b; else if (b > 2.0) b = b-2.0; else b = 2.0-b;
                    float a = (i+ 90)/180.0; if (a > 2.0) a = a-2.0; else if (a > 1.0) a = 2.0-a;
                    hue[0] = hue[4] = r;
                    hue[1] = hue[5] = g;
                    hue[2] = hue[6] = b;
                    hue[3] = a*0.5;
                    hue[7] = a*0.75;
                    
                    gradient = CGGradientCreateWithColorComponents(colorSpace, hue, NULL, 2);
                    CGContextSaveGState(context);
                    CGContextMoveToPoint(context, 15, 15);
                    CGContextAddArc(context, 15, 15, 10, i*DEG2RAD, (i+angle)*DEG2RAD, false);
                    CGContextClosePath(context);
                    CGContextClip(context);
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(x, y), CGPointMake(15, 15), 0);
                    CGContextRestoreGState(context);
                    CGGradientRelease(gradient);
                }
                
                CGContextStrokeEllipseInRect(context, CGRectMake(4.0, 4.0, 22.0, 22.0));
            }
                break;
            case BUTTON_SHARPNESS:
            {
                int x, y;
                
                // A gradient checkerboard, inside a rounded rect
                for (x = 5; x < 25; x+=2)
                {
                    float b = (x - 5)/19.0*0.5+0.375;
                    if (b > 0.75) b = 0.75;
                    else if (b < 0.5) b = 0.5;
                    
                    for (y = 5; y < 25; y+=2)
                    {
                        float k = ((x ^ y) & 2) ? b : 1.0-b;
                        CGContextSetRGBFillColor(context, k, k, k, k);
                        CGContextFillRect(context, CGRectMake(x, y, 2, 2));
                    }
                }
                
                CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
                CGContextMoveToPoint(context, 4, 15);
                CGContextAddArcToPoint(context, 4, 4, 15, 4, 4);
                CGContextAddArcToPoint(context, 26, 4, 26, 15, 4);
                CGContextAddArcToPoint(context, 26, 26, 15, 26, 4);
                CGContextAddArcToPoint(context, 4, 26, 4, 15, 4);
                CGContextClosePath(context);
                CGContextStrokePath(context);
            }
                break;
            default:
                break;
        }
        theCGImage = CGBitmapContextCreateImage(context);
        ((UITabBarItem *)[self.tabBar.items objectAtIndex:b]).image = [UIImage imageWithCGImage:theCGImage];
        CGImageRelease(theCGImage);
    }
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderAction:(UISlider *)sender {
    [self.eaglView updateValue];
}

#pragma mark - UITabBarDelegate
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self.eaglView updateTabbar];
}


@end
