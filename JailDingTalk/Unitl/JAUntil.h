//
//  JAUntil.h
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RGB(x,y,z)              [UIColor colorWithRed:(x)/255.0 green:(y)/255.0 blue:(z)/255.0 alpha:1.0]
#define RGBA(x,y,z,a)           [UIColor colorWithRed:(x)/255.0 green:(y)/255.0 blue:(z)/255.0 alpha:a]

@interface JAUntil : NSObject

+ (UIWindow *)keyWindow;

+ (void)showErrorToast:(NSString *)toast fromView:(UIView *)view;
+ (void)showSucessToast:(NSString *)toast fromView:(UIView *)view;
+ (void)showMessageToast:(NSString *)toast fromView:(UIView *)view;

+ (void)crashReport;
+ (BOOL)showCrashLog;

@end
