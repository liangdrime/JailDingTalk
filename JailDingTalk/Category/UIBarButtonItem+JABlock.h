//
//  UIBarButtonItem+JABlock.h
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import <UIKit/UIKit.h>

typedef void (^UIBarButtonItemActionBlock)(UIBarButtonItem *sender);

@interface UIBarButtonItem (JABlock)

+ (instancetype)barButtonItemWithImage:(UIImage *)image action:(UIBarButtonItemActionBlock)block;
+ (instancetype)barButtonItemWithTitle:(NSString *)title action:(UIBarButtonItemActionBlock)block;

@end
