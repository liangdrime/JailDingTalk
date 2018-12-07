//
//  JALocationSettingViewController.m
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import "JALocationSettingViewController.h"
#import <MapKit/MapKit.h>
#import "UIView+JAFrame.h"
#import "JAHelper.h"
#import "JALocationSearchView.h"
#import "JACenterAnnotationView.h"
#import "JAUntil.h"

@interface JATitleImageButton : UIButton

@property (nonatomic, assign) CGFloat verticalSpace;

@end

@implementation JATitleImageButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    titleRect.size.width = contentRect.size.width;
    CGSize imageSize = [self imageForState:UIControlStateNormal].size;
    titleRect.origin = CGPointMake(0, (contentRect.size.height + (imageSize.height + titleRect.size.height + _verticalSpace)) / 2);
    titleRect.origin.y = JAFloatPixelRound(titleRect.origin.y);
    return titleRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    CGRect titleRect = [self titleRectForContentRect:contentRect];
    imageRect.origin = CGPointMake((contentRect.size.width - imageRect.size.width) / 2, (contentRect.size.height - (imageRect.size.height + titleRect.size.height + 1)) / 2);
    imageRect.origin.x = JAFloatPixelRound(imageRect.origin.x);
    imageRect.origin.y = JAFloatPixelRound(imageRect.origin.y);
    return imageRect;
}

@end




static CGFloat const kLocationDistanMeter = 300;
static CGFloat const kAnnotationAnimationInterval = 0.2f;

@interface JALocationSettingViewController () <MKMapViewDelegate, CLLocationManagerDelegate> {
    CLLocationCoordinate2D _settingCoordinate;
    CLLocationManager *_locationManager;
    UIButton *_resetLocationButton;
    UIButton *_companyLocationButton;
    UIButton *_clearLocationButton;
}

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) JALocationSearchView *searchView;
@property (nonatomic, strong) JACenterAnnotationView *annotationView;
@property (nonatomic, assign) BOOL firstUpdateUserLocation;

@end

@implementation JALocationSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"定位设置";
    self.view.backgroundColor = [UIColor whiteColor];
    _firstUpdateUserLocation = YES;
    _settingCoordinate = [JAHelper savedLocationCoordinate];
    
    [self initViews]; // 38acff
    [self requestAuthorizationCompletion:^(BOOL flag) {
        if (flag) {
            [self loadMapView];
        }
    }];
}

- (void)initViews {
    // search bar view.
    JALocationSearchView *searchView = [JALocationSearchView new];
    _searchView = searchView;
    
    // annotation view.
    self.annotationView = [JACenterAnnotationView new];
    CGFloat scale = [UIScreen mainScreen].scale;
    _annotationView.center = CGPointMake(round(self.view.ja_width *scale / 2)/ scale, round(self.view.ja_height *scale / 2) / scale - 4);
    
    // bottom buttons.
    UIButton *resetLocationButton = [self buttonWithImage:@"reset_location_icon" shadow:NO border:YES action:@selector(locateUserLocation)];
    resetLocationButton.layer.cornerRadius = 3;
    resetLocationButton.ja_size = CGSizeMake(36, 36);
    resetLocationButton.ja_left = 15;
    resetLocationButton.ja_bottom = [[UIScreen mainScreen] bounds].size.height - 25;
    _resetLocationButton = resetLocationButton;
    
    UIButton *companyLocationButton = [self buttonWithImage:@"map_company_icon" shadow:NO border:YES action:@selector(locateCompany)];
    companyLocationButton.layer.cornerRadius = 3;
    companyLocationButton.ja_size = resetLocationButton.ja_size;
    companyLocationButton.ja_left = resetLocationButton.ja_left;
    companyLocationButton.ja_bottom = resetLocationButton.ja_top - 10;
    _companyLocationButton = companyLocationButton;
    
    JATitleImageButton *clearLocationButton = [JATitleImageButton buttonWithType:UIButtonTypeCustom];
    clearLocationButton.backgroundColor = [UIColor whiteColor];
    clearLocationButton.layer.borderColor = RGB(212, 212, 212).CGColor;
    clearLocationButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    clearLocationButton.layer.cornerRadius = 3;
    clearLocationButton.verticalSpace = -10;
    clearLocationButton.ja_size = CGSizeMake(36, 36);
    clearLocationButton.ja_right = [UIScreen mainScreen].bounds.size.width - 15;
    clearLocationButton.ja_bottom = resetLocationButton.ja_bottom;
    clearLocationButton.titleLabel.font = [UIFont systemFontOfSize:6];
    [clearLocationButton setTitleColor:RGB(81, 81, 81) forState:UIControlStateNormal];
    [clearLocationButton setTitle:@"清除设置" forState:UIControlStateNormal];
    [clearLocationButton setImage:[UIImage imageNamed:@"map_location_clear"] forState:UIControlStateNormal];
    [clearLocationButton addTarget:self action:@selector(clearLocation) forControlEvents:UIControlEventTouchUpInside];
    _clearLocationButton = clearLocationButton;
    
    [self.view addSubview:searchView];
    [self.view addSubview:resetLocationButton];
    [self.view addSubview:companyLocationButton];
    [self.view addSubview:clearLocationButton];
    [self.view addSubview:_annotationView];
    
    // actions.
    __weak typeof(self) weakSelf = self;
    searchView.leftButtonAction = ^{
        [weakSelf close];
    };
    searchView.rightButtonAction = ^{
        [weakSelf commit];
    };
    searchView.didSearch = ^(NSString *text) {
        [weakSelf search:text];
    };
}

- (void)loadMapView {
    // map view.
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.alpha = 0;
    [self.view insertSubview:_mapView atIndex:0];
    [self locateUserLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_annotationView ja_startLoading];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        _searchView.ja_top = self.view.safeAreaInsets.top + 20;
        _resetLocationButton.ja_bottom = [[UIScreen mainScreen] bounds].size.height - self.view.safeAreaInsets.bottom - 25;
        _clearLocationButton.ja_bottom = _resetLocationButton.ja_bottom;
        _companyLocationButton.ja_bottom = _resetLocationButton.ja_top - 10;
    }
}

- (UIButton *)buttonWithImage:(NSString *)imageName shadow:(BOOL)shadow border:(BOOL)border action:(SEL)action {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor whiteColor];
    if (shadow) {
        backButton.layer.shadowColor = RGB(221, 221, 221).CGColor;
        backButton.layer.shadowRadius = 2;
        backButton.layer.shadowOffset = CGSizeMake(0, -0.5);
        backButton.layer.shadowOpacity = 1;
    }
    if (border) {
        backButton.layer.borderColor = RGB(212, 212, 212).CGColor;
        backButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    }
    [backButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [backButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return backButton;
}

- (void)requestAuthorizationCompletion:(void(^)(BOOL flag))completion {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted: {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            [_locationManager requestWhenInUseAuthorization];
            [_locationManager requestAlwaysAuthorization];
        }
            break;
        case kCLAuthorizationStatusDenied: {
            
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if (completion) {
                completion(YES);
            }
            break;
        default:
            break;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status > kCLAuthorizationStatusDenied) {
        [self loadMapView];
    }
}

#pragma mark - MKMapViewDelegate method

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    // only update region once time.
    if (_firstUpdateUserLocation) {
        
        _firstUpdateUserLocation = NO;
        
        // update map view to user location.
        CLLocationCoordinate2D coordinate = [userLocation coordinate];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, kLocationDistanMeter, kLocationDistanMeter);
        [self.mapView setRegion:region animated:YES];
        
        if (_settingCoordinate.latitude <= 0 && _settingCoordinate.longitude <= 0) {
            _settingCoordinate = coordinate;
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if ([self mapViewRegionDidChangeFromUserInteraction] && _searchView.searchInputView.isFirstResponder) {
        [_searchView.searchInputView resignFirstResponder];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:_annotationView selector:@selector(ja_startAnimation) object:nil];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (_firstUpdateUserLocation) {
        return;
    }
    
    // animation the annotation with a delay to avoid do it frequently.
    [_annotationView performSelector:@selector(ja_startAnimation) withObject:nil afterDelay:kAnnotationAnimationInterval];
    
    // show the map view after first load user location.
    if (_mapView.alpha == 0) {
        [UIView animateWithDuration:0.15 animations:^{
            self.mapView.alpha = 1;
        } completion:^(BOOL finished) {
            [self.annotationView ja_stopLoading];
        }];
    }
}

/*
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location"];
    annotationView.image = [UIImage imageNamed:@""];
    return annotationView;
}
 */

#pragma mark -

- (BOOL)mapViewRegionDidChangeFromUserInteraction {
    UIView *view = self.mapView.subviews.firstObject;
    // Look through gesture recognizers to determine whether this region change is from user interaction
    for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
            return YES;
        }
    }
    return NO;
}

- (void)search:(NSString *)keyword {
    if (![keyword isKindOfClass:[NSString class]] || keyword.length == 0) {
        return;
    }
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    [[[CLGeocoder alloc] init] geocodeAddressString:keyword completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            [JAUntil showErrorToast:@"搜索位置失败，请重试！" fromView:self.view];
            return;
        }
        CLLocation *userLocation = self.mapView.userLocation.location;
        CLLocation *targetLocation = userLocation;
        double distance = DBL_MAX;
        
        for (CLPlacemark *place in placemarks) {
            // just get the near location.
            CLLocationCoordinate2D coordinate = place.location.coordinate;
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            double c_distance = [location distanceFromLocation:userLocation];
            if (c_distance < distance) {
                distance = c_distance;
                targetLocation = location;
            }
        }
        
        // change the map view location.
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(targetLocation.coordinate, kLocationDistanMeter, kLocationDistanMeter);
        [self.mapView setRegion:region animated:YES];
    }];
}

- (void)locateUserLocation {
    CLLocationCoordinate2D coordinate = _mapView.userLocation.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, kLocationDistanMeter, kLocationDistanMeter);
    [_mapView setRegion:region animated:YES];
}

- (void)locateCompany {
    CLLocationCoordinate2D coordinate = [JAHelper savedLocationCoordinate];
    if (coordinate.latitude <= 0 && coordinate.longitude <= 0) {
        [JAUntil showMessageToast:@"未设置公司位置" fromView:self.view];
        return;
    }
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, kLocationDistanMeter, kLocationDistanMeter);
    [_mapView setRegion:region animated:YES];
}

- (void)clearLocation {
    [JAHelper clearLocation];
    [self locateUserLocation];
    [JAUntil showSucessToast:@"成功清除位置设置！" fromView:self.view];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)commit {
    // get the current location.
    CGPoint annotationOffset = CGPointMake(0, -10);
    CGPoint point = CGPointMake(CGRectGetMidX(_annotationView.frame) + annotationOffset.x, CGRectGetMaxY(_annotationView.frame) + annotationOffset.y);
    _settingCoordinate = [_mapView convertPoint:point toCoordinateFromView:_annotationView.superview];
    
    // dismiss
    [self dismissViewControllerAnimated:YES completion:^{
        [JAHelper saveLocation:self->_settingCoordinate];
        [JAUntil showSucessToast:@"位置设置成功🙃😉" fromView:[JAUntil keyWindow]];
    }];
}

@end


