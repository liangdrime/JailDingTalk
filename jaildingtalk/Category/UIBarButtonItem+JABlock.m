//
//  UIBarButtonItem+JABlock.m
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import "UIBarButtonItem+JABlock.h"
#import <objc/runtime.h>

static const void *UIBarButtonItemBlockKey = &UIBarButtonItemBlockKey;

@interface UIBarButtonItem (JABlocksInternal)

- (void)handleAction:(UIBarButtonItem *)barButtonItem;

@end

@implementation UIBarButtonItem (JABlock)

+ (instancetype)barButtonItemWithImage:(UIImage *)image action:(UIBarButtonItemActionBlock)block {
    return [[self.class alloc] initWithImage:image action:block];
}

+ (instancetype)barButtonItemWithTitle:(NSString *)title action:(UIBarButtonItemActionBlock)block {
    return [[self.class alloc] initWithTitle:title action:block];
}

- (instancetype)initWithImage:(UIImage *)image action:(UIBarButtonItemActionBlock)block {
    self = [self initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(handleAction:)];
    if (!self) return nil;
    
    self.ja_action = block;
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title action:(UIBarButtonItemActionBlock)block {
    self = [self initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(handleAction:)];
    if (!self) return nil;
    
    self.ja_action = block;
    
    return self;
}

- (void)handleAction:(UIBarButtonItem *)barButtonItem {
    UIBarButtonItemActionBlock action = barButtonItem.ja_action;
    if (action) {
        action(self);
    }
}

- (void)setJa_action:(UIBarButtonItemActionBlock)action {
    objc_setAssociatedObject(self, UIBarButtonItemBlockKey, action, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIBarButtonItemActionBlock)ja_action {
    return objc_getAssociatedObject(self, UIBarButtonItemBlockKey);
}

@end

