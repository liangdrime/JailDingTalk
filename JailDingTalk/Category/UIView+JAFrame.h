//
//  UIView+JAFrame.h
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import <UIKit/UIKit.h>

@interface UIView (JAFrame)

@property (nonatomic, assign) CGFloat ja_x;
@property (nonatomic, assign) CGFloat ja_y;
@property (nonatomic, assign) CGFloat ja_width;
@property (nonatomic, assign) CGFloat ja_height;
@property (nonatomic, assign) CGFloat ja_centerX;
@property (nonatomic, assign) CGFloat ja_centerY;
@property (nonatomic, assign) CGSize ja_size;
@property (nonatomic, assign) CGFloat ja_top;
@property (nonatomic, assign) CGFloat ja_bottom;
@property (nonatomic, assign) CGFloat ja_left;
@property (nonatomic, assign) CGFloat ja_right;

CGFloat JAFloatPixelFloor(CGFloat value);
CGFloat JAFloatPixelRound(CGFloat value);
CGFloat JAScreenScale();

@end
