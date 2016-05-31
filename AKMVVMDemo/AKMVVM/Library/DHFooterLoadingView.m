//
//  DHFooterLoadingView.m
//  DHClient
//
//  Created by xinjian.jiang on 15/9/21.
//  Copyright © 2015年 com.jiangxinjian. All rights reserved.
//

#import "DHFooterLoadingView.h"

const CGFloat DHFooterLoadingHeight = 44.0;

@implementation DHFooterLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.footerLoadingViewType = DHFooterLoadingViewTypeRemove;
        [self loadUI];
        
//        self.loadingView = [DHLoadingView setOnView:self withTitle:@"" animated:YES];
//        [self.loadingView start];
//        if ([DHFlagUtils settingOpenNightMode])
//        {
//            self.loadingView.lineTintColor = [UIColor colorWithHexString:@"#333333"];
//        }
//        else
//        {
//            self.loadingView.lineTintColor = [UIColor colorWithHexString:@"#cccccc"];
//        }
//        self.loadingView.center = CGPointMake(self.width/2, self.height/2);
    }
    return self;
}


- (void)loadUI
{
    self.loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicatorView.hidden = YES;
    [self addSubview:self.loadingIndicatorView];
}


- (void)startAnimating
{
    if (!self.loadingIndicatorView) {
        [self loadUI];
    }
    self.height = DHFooterLoadingHeight;
    self.loadingIndicatorView.frame = RECT(0, 0, 40, 40);
    self.loadingIndicatorView.center = CGPointMake(SCREEN_SIZE.width/2, DHFooterLoadingHeight/2);
    [self.loadingIndicatorView startAnimating];
    self.loadingIndicatorView.hidden = NO;
//    [self.loadingView start];
}


- (void)stopAnimating
{
    self.height = 0;
    [self.loadingIndicatorView stopAnimating];
    self.loadingIndicatorView.hidden = YES;
//    [self.loadingView stop];
}

@end
