//
//  JALocationHelper.m
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import "JALocationHelper.h"

NSString *const kLocationLongitude = @"kLocationLongitude";
NSString *const kLocationLatitude = @"kLocationLatitude";

@implementation JALocationHelper

+ (CLLocation *)filteredLocation:(CLLocation *)location {
    
    id latitude_base_string = [[NSUserDefaults standardUserDefaults] objectForKey:kLocationLatitude];
    id longitude_base_string = [[NSUserDefaults standardUserDefaults] objectForKey:kLocationLongitude];
    
    if(!longitude_base_string || !latitude_base_string) {
        return location;
    }
    
    return location;
    
    /*
    double latitude_base = [latitude_base_string floatValue];
    double longitude_base = [longitude_base_string floatValue];
    
    NSInteger offset_lon = arc4random() % 100;
    NSInteger offset_lat = arc4random() % 100;
    
    double longitude = longitude_base + (double)(offset_lon * 0.000001);
    double latitude = latitude_base + (double)(offset_lat * 0.000001);
    
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(latitude, longitude);
    // Transform the GPS location to GD.
    coordinate2D = TransformCoordinate(coordinate2D);
    
    CLLocation *currentLocation = nil;
    
    if(location) {
        currentLocation = [[CLLocation alloc] initWithCoordinate:coordinate2D altitude:location.altitude horizontalAccuracy:location.horizontalAccuracy verticalAccuracy:location.verticalAccuracy course:location.course speed:location.speed timestamp:location.timestamp];
    }
    else {
        currentLocation = [[CLLocation alloc] initWithCoordinate:coordinate2D altitude:location.altitude horizontalAccuracy:65.000000 verticalAccuracy:10.000000 course:-1.000000 speed:-1.000000 timestamp:[NSDate date]];
    }
    
    return currentLocation;
     */
}

+ (void)saveLocation:(CLLocationCoordinate2D)coordinate {
    [[NSUserDefaults standardUserDefaults] setDouble:coordinate.longitude forKey:kLocationLongitude];
    [[NSUserDefaults standardUserDefaults] setDouble:coordinate.latitude forKey:kLocationLatitude];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (CLLocationCoordinate2D)savedLocationCoordinate {
    id longitude = [[NSUserDefaults standardUserDefaults] valueForKey:kLocationLongitude];
    id latitude = [[NSUserDefaults standardUserDefaults] valueForKey:kLocationLatitude];
    
    return (CLLocationCoordinate2D){[latitude doubleValue], [longitude doubleValue]};
}

+ (void)clearLocation {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kLocationLongitude];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kLocationLatitude];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -

// Transform the GPS location to GD.
CLLocationCoordinate2D TransformCoordinate(CLLocationCoordinate2D coordinate) {
    double a = 6378245.0;
    double ee = 0.00669342162296594323;
    double dLat = transformLat(coordinate.longitude - 105.0, coordinate.latitude - 35.0);
    double dLon = transformLon(coordinate.longitude - 105.0, coordinate.latitude - 35.0);
    double radLat = coordinate.latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(coordinate.latitude - dLat, coordinate.longitude - dLon);
    
    return coord;
}

static double transformLon(double x, double y) {
    
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

static double transformLat(double x, double y) {
    
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

@end
