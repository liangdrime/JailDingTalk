//
//  JAUntil.m
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import "JAUntil.h"

@implementation JAUntil

+ (UIWindow *)keyWindow {
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    return window;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
+ (void)showErrorToast:(NSString *)toast fromView:(UIView *)view {
    if ([view respondsToSelector:@selector(dt_postError:)]) {
        [view performSelector:@selector(dt_postError:) withObject:toast];
    }
}

+ (void)showSucessToast:(NSString *)toast fromView:(UIView *)view {
    if ([view respondsToSelector:@selector(dt_postSuccess:)]) {
        [view performSelector:@selector(dt_postSuccess:) withObject:toast];
    }
}

+ (void)showMessageToast:(NSString *)toast fromView:(UIView *)view {
    if ([view respondsToSelector:@selector(dt_postMessage:)]) {
        [view performSelector:@selector(dt_postMessage:) withObject:toast];
    }
}
#pragma clang diagnostic pop

#pragma mark - Debug

void JAUncaughtExceptionHandler(NSException *exception) {
    NSData *data = nil;
    if ([exception respondsToSelector:@selector(yy_modelToJSONData)]) {
        data = [exception performSelector:@selector(yy_modelToJSONData)];
        if (data) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ja_crash_log"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        dic[@"name"] = exception.name;
        dic[@"callStack"] = exception.callStackSymbols;
        dic[@"reason"] = exception.reason;
        
        data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        if (data) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ja_crash_log"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

+ (void)crashReport {
    NSSetUncaughtExceptionHandler(&JAUncaughtExceptionHandler);
}

+ (BOOL)showCrashLog {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ja_crash_log"];
    if (data) {
        NSString *log = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        UITextView *texView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 450)];
        texView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
        texView.backgroundColor = [UIColor whiteColor];
        texView.textColor = [UIColor blackColor];
        texView.font = [UIFont systemFontOfSize:14];
        texView.text = log;
        
        [[self keyWindow] addSubview:texView];
        return YES;
    }
    return NO;
}

@end
