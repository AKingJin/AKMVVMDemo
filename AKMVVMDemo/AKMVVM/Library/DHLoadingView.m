//
//  DHLoadingView.m
//  DHClient
//
//  Created by xinjian.jiang on 15/2/6.
//  Copyright (c) 2015年 com.jiangxinjian. All rights reserved.
//

#import "DHLoadingView.h"

#define ANGLE(a) 2*M_PI/360*a

@interface DHLoadingView ()
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, assign) BOOL isSpinning;
@end

@implementation DHLoadingView

//-----------------------------------
// Add the loader to view
//-----------------------------------

+ (DHLoadingView *)setOnView:(UIView *)view withTitle:(NSString *)title animated:(BOOL)animated {
    DHLoadingView *hud = [[DHLoadingView alloc] initWithFrame:GMD_SPINNER_FRAME];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-70.0f, 40.0f, 200.0f, 42.0f)];
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    label.textColor = GMD_SPINNER_COLOR;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [hud addSubview:label];
    
    
    [hud start];
    [view addSubview:hud];
    float height = view.frame.size.height;
    float width = view.frame.size.width;
    CGPoint center = CGPointMake(width/2, height/2);
    hud.center = center;
    return hud;
}

//------------------------------------
// Hide the leader in view
//------------------------------------
+ (BOOL)hideFromView:(UIView *)view animated:(BOOL)animated {
    DHLoadingView *hud = [DHLoadingView HUDForView:view];
    [hud stop];
    if (hud) {
        [hud removeFromSuperview];
        return YES;
    }
    return NO;
}

//------------------------------------
// Perform search for loader and hide it
//------------------------------------
+ (DHLoadingView *)HUDForView: (UIView *)view {
    DHLoadingView *hud = nil;
    NSArray *subViewsArray = view.subviews;
    Class hudClass = [DHLoadingView class];
    for (UIView *aView in subViewsArray) {
        if ([aView isKindOfClass:hudClass]) {
            hud = (DHLoadingView *)aView;
        }
    }
    return hud;
}

#pragma mark - Initialization
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup
- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    
    //---------------------------
    // Set line width
    //---------------------------
    _lineWidth = GMD_SPINNER_LINE_WIDTH;
    
    //---------------------------
    // Round Progress View
    //---------------------------
    self.backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.strokeColor = GMD_SPINNER_COLOR.CGColor;
    _backgroundLayer.fillColor = self.backgroundColor.CGColor;
    _backgroundLayer.lineCap = kCALineCapRound;
    _backgroundLayer.lineWidth = _lineWidth;
    [self.layer addSublayer:_backgroundLayer];
    
    
}


-(void)setLineTintColor:(UIColor *)lineTintColor
{
    _backgroundLayer.strokeColor = lineTintColor.CGColor;
}



- (void)drawRect:(CGRect)rect {
    //-------------------------
    // Make sure layers cover the whole view
    //-------------------------
    _backgroundLayer.frame = self.bounds;
}

#pragma mark - Drawing

- (void)drawBackgroundCircle:(BOOL) partial {
    CGFloat startAngle = - ((float)M_PI / 2); // 90 Degrees
    CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (self.bounds.size.width - _lineWidth)/2;
    
    //----------------------
    // Begin draw background
    //----------------------
    
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = _lineWidth;
    
    //---------------------------------------
    // Make end angle to 90% of the progress
    //---------------------------------------
    if (partial) {
        endAngle = (1.8f * (float)M_PI) + startAngle;
    }
    [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    _backgroundLayer.path = processBackgroundPath.CGPath;
}

#pragma mark - Spin
- (void)start {
    if (self.isSpinning) {
        return;
    }
    self.isSpinning = YES;
    [self drawBackgroundCircle:YES];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [_backgroundLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stop{
    [self drawBackgroundCircle:NO];
    [_backgroundLayer removeAllAnimations];
    self.isSpinning = NO;
}

@end
