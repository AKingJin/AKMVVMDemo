//
//  DHFooterLoadingView.h
//  DHClient
//
//  Created by xinjian.jiang on 15/9/21.
//  Copyright © 2015年 com.jiangxinjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHLoadingView.h"

extern const CGFloat DHFooterLoadingHeight;

typedef NS_ENUM(NSInteger, DHFooterLoadingViewType) {
    DHFooterLoadingViewTypeRemove,
    DHFooterLoadingViewTypeLoad,
    DHFooterLoadingViewTypeReload,
};

@interface DHFooterLoadingView : UICollectionReusableView

//@property (nonatomic, strong) DHLoadingView *loadingView;

@property (nonatomic, strong) UIActivityIndicatorView   *loadingIndicatorView;

@property (nonatomic, assign) DHFooterLoadingViewType   footerLoadingViewType;

- (void)startAnimating;

- (void)stopAnimating;

@end
