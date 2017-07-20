//
//  JALocationSearchView.m
//  jaildingtalk
//
//  Created by Roylee on 2017/7/19.
//
//

#import "JALocationSearchView.h"
#import "JAUntil.h"
#import "UIView+JAFrame.h"

CGFloat const kJALocationSearchViewHeight = 50;

@interface JALocationSearchView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UITextField *searchInputView;

@end

@implementation JALocationSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    frame = CGRectMake(15, 20, [[UIScreen mainScreen] bounds].size.width - 2 *15, kJALocationSearchViewHeight);
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundView = [UIImageView new];
    _backgroundView.ja_size = self.ja_size;
    _backgroundView.backgroundColor = [UIColor whiteColor];
    _backgroundView.layer.shadowColor = RGB(212, 212, 212).CGColor;
    _backgroundView.layer.shadowOffset = CGSizeMake(0, 1);
    _backgroundView.layer.shadowRadius = 4;
    _backgroundView.layer.shadowOpacity = 1;
    _backgroundView.layer.cornerRadius = 3;
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton.ja_size = CGSizeMake(30, 30);
    _leftButton.ja_centerY = self.ja_height / 2;
    _leftButton.ja_left = 10;
    [_leftButton setImage:[UIImage imageNamed:@"map_nav_close"] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.ja_size = CGSizeMake(30, 30);
    _rightButton.ja_centerY = self.ja_height / 2;
    _rightButton.ja_right = self.ja_width - 10;
    [_rightButton setImage:[UIImage imageNamed:@"map_nav_confirm"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    self.searchInputView = [[UITextField alloc] init];
    _searchInputView.ja_left = _leftButton.ja_right + 2 *10;
    _searchInputView.ja_top = 1;
    _searchInputView.ja_size = CGSizeMake(_rightButton.ja_left - _leftButton.ja_right - 4 *10, self.ja_height);
    _searchInputView.delegate = self;
    _searchInputView.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchInputView.tintColor = RGB(85, 85, 85);
    _searchInputView.font = [UIFont systemFontOfSize:16];
    _searchInputView.textColor = RGB(68, 68, 68);
    _searchInputView.returnKeyType = UIReturnKeySearch;
    _searchInputView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"搜索公司位置并保存" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName : RGB(153, 153, 153)}];
    
    UIView *leftLine = [UIView new];
    leftLine.backgroundColor = RGB(205, 205, 205);
    leftLine.ja_size = CGSizeMake(1 / [UIScreen mainScreen].scale, 22);
    leftLine.ja_centerY = _leftButton.ja_centerY;
    leftLine.ja_left = _leftButton.ja_right + 10;
    
    UIView *rightLine = [UIView new];
    rightLine.backgroundColor = leftLine.backgroundColor;
    rightLine.ja_size = leftLine.ja_size;
    rightLine.ja_centerY = leftLine.ja_centerY;
    rightLine.ja_right = _rightButton.ja_left - 10;
    
    [self addSubview:_backgroundView];
    [self addSubview:_leftButton];
    [self addSubview:_rightButton];
    [self addSubview:_searchInputView];
    [self addSubview:leftLine];
    [self addSubview:rightLine];
}

- (void)buttonClick:(UIButton *)sender {
    if (sender == _leftButton) {
        if ([_searchInputView isFirstResponder]) {
            [_searchInputView resignFirstResponder];
        }else if (_leftButtonAction) {
            _leftButtonAction();
        }
    }else if (sender == _rightButton) {
        if (_rightButtonAction) {
            _rightButtonAction();
        }
    }
}

#pragma mark - 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [_searchInputView resignFirstResponder];
        
        if (_didSearch) {
            _didSearch(textField.text);
        }
    }
    return YES;
}

@end
