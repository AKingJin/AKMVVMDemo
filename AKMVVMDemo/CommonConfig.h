//
//  CommonConfig.h
//  DHOCChat
//
//  Created by AKing on 16/3/11.
//  Copyright © 2016年 AKing. All rights reserved.
//

#ifndef CommonConfig_h
#define CommonConfig_h

/**
 *  系统define。。。
 */

#define IS_IPHONE                               ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] || [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone Simulator" ])
#define IS_IPAD                                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IOS7_OR_LATER                           ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
#define IOS8_OR_LATER                           ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending)
#define IOS9_OR_LATER                           ([[[UIDevice currentDevice] systemVersion] compare:@"9.0"] != NSOrderedAscending)
#define IS_IPHONE_4_SCREEN                      [[UIScreen mainScreen] bounds].size.height >= 480.0f && [[UIScreen mainScreen] bounds].size.height < 568.0f
#define SCREEN_SIZE                             [[UIScreen mainScreen] bounds].size

#define APP_VERSION                             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_DELEGATE                            (AppDelegate *)[UIApplication sharedApplication].delegate
#define APP_WINDOW                              ((AppDelegate *)[UIApplication sharedApplication].delegate).window
#define APP_ROOTVC                              [(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController
#define NAV(rootVC)                             [[UINavigationController alloc] initWithRootViewController:rootVC]
#define WINDOW                                  ((AppDelegate *)[UIApplication sharedApplication].delegate).window

/** Size */
#define RECT(x, y, width, height)               CGRectMake((x), (y), (width), (height))
#define SIZE(width, height)                     CGSizeMake((width), (height))
#define POINT(x, y)                             CGPointMake((x), (y))

/** Font */
#define SYS_FONT(s)                             [UIFont systemFontOfSize:s]
#define SYS_BOLD_FONT(s)                        [UIFont boldSystemFontOfSize:s]
//#define DEFAULT_FONT(s)                         [UIFont fontWithName:@"NotoSansHans-DemiLight" size:s]

/** Color */
#define CLEAR_COLOR                             [UIColor clearColor]
#define COLOR_WITH_HEX(str)                     [UIColor colorWithHexString:str]
#define COLOR_WITH_RGB(r, g, b)                 [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define COLOR_WITH_RGBA(r, g, b, a)             [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define UIColorFromRGB(rgbValue)                [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


typedef void(^CommonBlock)(id response);
#define WeakSelf(wself) __weak __typeof(&*self) wself = self;
#define IS_STRING_NIL(str)                      (([[str removeWhiteSpacesFromString] isEqualToString:@""] || str == nil || [str isEqualToString:@"(null)"]) ? YES : NO) || [str isKindOfClass:[NSNull class]]
#define String(num)                             [NSString stringWithFormat:@"%d", num]

#define MJVIEWHEIGHT                            64.0f



//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif


//重写NSLog,Debug模式下打印日志和当前行数
//#if DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...) nil
//#endif

//DEBUG  模式下打印日志,当前行 并弹出一个警告
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif


#endif /* CommonConfig_h */
