//
//  JACenterAnnotationView.m
//  jaildingtalk
//
//  Created by Roylee on 2017/7/19.
//
//

#import "JACenterAnnotationView.h"
#import "JAUntil.h"
#import "UIView+JAFrame.h"

static CGFloat const kJAAnnotationCircleHeight = 22;
static CGFloat const kJAAnnotationLineYOffset = 12;
static CGFloat const kJAAnnotationLineHeight = 10 + kJAAnnotationLineYOffset;

@interface JACenterAnnotationView ()

@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UIView *centerCircleView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) CAShapeLayer *loadingLayer1;
@property (nonatomic, strong) CAShapeLayer *loadingLayer2;

@end

@implementation JACenterAnnotationView

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake(kJAAnnotationCircleHeight, kJAAnnotationCircleHeight + kJAAnnotationLineHeight  + 2);
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kJAAnnotationCircleHeight, kJAAnnotationCircleHeight)];
    _circleView.backgroundColor = RGB(22, 194, 149);
    _circleView.layer.cornerRadius = _circleView.ja_height / 2;
    _circleView.layer.borderWidth = 1;
    _circleView.layer.borderColor = RGB(15, 160, 110).CGColor;
    
    self.centerCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 7)];
    _centerCircleView.layer.cornerRadius = _centerCircleView.ja_height / 2;
    _centerCircleView.backgroundColor = RGB(240, 240, 240);
    _centerCircleView.center = CGPointMake(_circleView.ja_width / 2, _circleView.ja_height / 2);
    
    self.lineView = [UIView new];
    _lineView.ja_size = CGSizeMake(2, kJAAnnotationLineHeight);
    _lineView.ja_centerX = _circleView.ja_width / 2;
    _lineView.ja_top = _circleView.ja_bottom - kJAAnnotationLineYOffset;
    UIView *line = [[UIView alloc] initWithFrame:_lineView.bounds];
    line.backgroundColor = RGB(15, 160, 110);
    line.layer.cornerRadius = 1;
    
    CAShapeLayer *lineShadow = [CAShapeLayer new];
    lineShadow.frame = CGRectMake(-1.5, _lineView.ja_height - 2, 2 *1.5 + _lineView.ja_width, 3);
    lineShadow.fillColor = RGB(153, 153, 153).CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:lineShadow.bounds];
    lineShadow.path = path.CGPath;
    
    [_circleView addSubview:_centerCircleView];
    [_lineView.layer addSublayer:lineShadow];
    [_lineView addSubview:line];
    [self addSubview:_lineView];
    [self addSubview:_circleView];
}

#pragma mark -

- (void)ja_startAnimation {
    CGPoint circleCenter = CGPointMake(_circleView.ja_width / 2, _circleView.ja_height / 2);
    CGPoint lineCenter = CGPointMake(circleCenter.x, _circleView.ja_height - kJAAnnotationLineYOffset + _lineView.ja_height / 2);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _circleView.center = CGPointMake(circleCenter.x, circleCenter.y - 12);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _circleView.center = circleCenter;
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.25 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _lineView.center = CGPointMake(lineCenter.x, lineCenter.y - 12);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _lineView.center = lineCenter;
        } completion:nil];
    }];
}

- (void)ja_startLoading {
    if (!_loadingLayer1) {
        self.loadingLayer1 = [CAShapeLayer new];
        _loadingLayer1.fillColor = [UIColor whiteColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:_centerCircleView.frame];
        _loadingLayer1.path = path.CGPath;
        [_circleView.layer insertSublayer:_loadingLayer1 below:_centerCircleView.layer];
    }
    
    if (!_loadingLayer2) {
        self.loadingLayer2 = [CAShapeLayer new];
        _loadingLayer2.fillColor = _circleView.backgroundColor.CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:_centerCircleView.frame];
        _loadingLayer2.path = path.CGPath;
        [_circleView.layer insertSublayer:_loadingLayer2 above:_loadingLayer1];
    }
    
    CGFloat duration = 0.75f;
    UIBezierPath *toPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(_circleView.bounds, _circleView.layer.borderWidth, _circleView.layer.borderWidth)];
    
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    animation1.duration = duration *2;
    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation1.values = @[(id)_loadingLayer1.path, (id)toPath.CGPath, (id)toPath.CGPath];
    animation1.keyTimes = @[@0, @0.5, @1];
    animation1.repeatCount = HUGE_VALF;
    
    CAKeyframeAnimation *animation2 = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    animation2.duration = duration *2;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation2.values = @[(id)_loadingLayer2.path, (id)_loadingLayer2.path, (id)toPath.CGPath];
    animation2.keyTimes = @[@0, @0.5, @1];
    animation2.repeatCount = HUGE_VALF;
    
    [_loadingLayer1 addAnimation:animation1 forKey:@"loading1"];
    [_loadingLayer2 addAnimation:animation2 forKey:@"loading2"];
}

- (void)ja_stopLoading {
    [_loadingLayer1 removeAnimationForKey:@"loading1"];
    [_loadingLayer1 removeFromSuperlayer];
    [self setLoadingLayer1:nil];
    [_loadingLayer2 removeAnimationForKey:@"loading2"];
    [_loadingLayer2 removeFromSuperlayer];
    [self setLoadingLayer2:nil];
}


@end
