//
//  JALocationSearchView.h
//  jaildingtalk
//
//  Created by Roylee on 2017/7/19.
//
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const kJALocationSearchViewHeight;

@interface JALocationSearchView : UIView

@property (nonatomic, readonly) UITextField *searchInputView;
@property (nonatomic, copy) void(^leftButtonAction)();
@property (nonatomic, copy) void(^rightButtonAction)();
@property (nonatomic, copy) void(^didSearch)(NSString *text);

@end
