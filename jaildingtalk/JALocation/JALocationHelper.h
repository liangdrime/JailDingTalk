//
//  JALocationHelper.h
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

UIKIT_EXTERN NSString *const kLocationLongitude;
UIKIT_EXTERN NSString *const kLocationLatitude;

@interface JALocationHelper : NSObject

/// Return the custom location by a offset random.
+ (CLLocation *)filteredLocation:(CLLocation *)location;
/// Save the custom location.
+ (void)saveLocation:(CLLocationCoordinate2D)coordinate;
/// Get the saved location coordinate.
+ (CLLocationCoordinate2D)savedLocationCoordinate;
/// Clear location.
+ (void)clearLocation;

/// Transform GaoDe location to GPS.
/// Because different map use different standard, code see `https://github.com/JackZhouCn/JZLocationConverter`.
CLLocationCoordinate2D TransformCoordinate(CLLocationCoordinate2D coordinate);

@end
