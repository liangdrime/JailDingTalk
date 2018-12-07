//
//  UIView+JAFrame.m
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import <UIKit/UIKit.h>

@implementation UIView (JAFrame)

- (CGFloat)ja_x {
    return self.frame.origin.x;
}

- (void)setJa_x:(CGFloat)x {
    CGRect rect = self.frame;
    if (rect.origin.x == x) {
        return;
    }
    rect.origin.x = x;
    self.frame = rect;
}

- (CGFloat)ja_y {
    return self.frame.origin.y;
}

- (void)setJa_y:(CGFloat)y {
    CGRect rect = self.frame;
    if (rect.origin.y == y) {
        return;
    }
    rect.origin.y = y;
    self.frame = rect;
}

- (CGFloat)ja_width {
    return self.frame.size.width;
}

- (void)setJa_width:(CGFloat)width {
    CGRect rect = self.frame;
    if (rect.size.width == width) {
        return;
    }
    rect.size.width = width;
    self.frame = rect;
}

- (CGFloat)ja_height {
    return self.frame.size.height;
}

- (void)setJa_height:(CGFloat)height {
    CGRect rect = self.frame;
    if (rect.size.height == height) {
        return;
    }
    rect.size.height = height;
    self.frame = rect;
}

- (CGFloat)ja_centerX {
    return self.center.x;
}

- (void)setJa_centerX:(CGFloat)centerX {
    CGPoint center = self.center;
    if (center.x == centerX) {
        return;
    }
    center.x = centerX;
    self.center = center;
}

- (CGFloat)ja_centerY {
    return self.center.y;
}

- (void)setJa_centerY:(CGFloat)centerY {
    CGPoint center = self.center;
    if (center.y == centerY) {
        return;
    }
    center.y = centerY;
    self.center = center;
}

- (CGSize)ja_size {
    return self.frame.size;
}

- (void)setJa_size:(CGSize)size {
    CGRect frame = self.frame;
    if (CGSizeEqualToSize(frame.size, size)) {
        return;
    }
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)ja_top {
    return self.frame.origin.y;
}

- (void)setJa_top:(CGFloat)t {
    if (self.ja_top == t) {
        return;
    }
    self.frame = CGRectMake(self.ja_left, t, self.ja_width, self.ja_height);
}

- (CGFloat)ja_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setJa_bottom:(CGFloat)b {
    if (self.ja_bottom == b) {
        return;
    }
    self.frame = CGRectMake(self.ja_left, b - self.ja_height, self.ja_width, self.ja_height);
}

- (CGFloat)ja_left {
    return self.frame.origin.x;
}

- (void)setJa_left:(CGFloat)l {
    if (self.ja_left == l) {
        return;
    }
    self.frame = CGRectMake(l, self.ja_top, self.ja_width, self.ja_height);
}

- (CGFloat)ja_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setJa_right:(CGFloat)r {
    if (self.ja_right == r) {
        return;
    }
    self.frame = CGRectMake(r - self.ja_width, self.ja_top, self.ja_width, self.ja_height);
}

/// floor value for pixel-aligned
CGFloat JAFloatPixelFloor(CGFloat value) {
    CGFloat scale = JAScreenScale();
    return floor(value * scale) / scale;
}

/// round value for pixel-aligned
CGFloat JAFloatPixelRound(CGFloat value) {
    CGFloat scale = JAScreenScale();
    return round(value * scale) / scale;
}

CGFloat JAScreenScale() {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}

@end
