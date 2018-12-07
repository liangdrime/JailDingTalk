//
//  JAWifiHook.h
//  jaildingtalk
//
//  Created by Roylee on 2017/8/16.
//
//

#import <Foundation/Foundation.h>

@class JAWifiModel;
@interface JAWifiHook : NSObject

/// set the hooked wifi info.
+ (void)hookWifiInfo:(JAWifiModel *)wifi;

/// read the hooked wifi info.
+ (JAWifiModel *)wifiHooked;

@end
