//
//  JAWifiHook.m
//  jaildingtalk
//
//  Created by Roylee on 2017/8/16.
//
//

#import "JAWifiHook.h"
#import "JAWifiModel.h"
#import "JAFishHook.h"
#import <SystemConfiguration/SCNetworkReachability.h>

static NSString *const JA_WIFI_HOOKED = @"JA_WIFI_HOOKED";
@implementation JAWifiHook

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ja_rebind_symbols((struct _ja_rebinding[3]){
            {"CNCopySupportedInterfaces", ja_CNCopySupportedInterfaces, (void *)&orig_CNCopySupportedInterfaces},
            {"CNCopyCurrentNetworkInfo", ja_CNCopyCurrentNetworkInfo, (void *)&orig_CNCopyCurrentNetworkInfo},
            {"SCNetworkReachabilityGetFlags", ja_SCNetworkReachabilityGetFlags, (void *)&orig_SCNetworkReachabilityGetFlags},
        }, 3);
    });
}

+ (void)hookWifiInfo:(JAWifiModel *)wifi {
    if(wifi) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:wifi];
        if(data) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:JA_WIFI_HOOKED];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JA_WIFI_HOOKED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (JAWifiModel *)wifiHooked {
    JAWifiModel *wifi = nil;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:JA_WIFI_HOOKED];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(data && [data isKindOfClass:[NSData class]]) {
        wifi = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return wifi;
}

// CFArrayRef CNCopySupportedInterfaces	(void)
static CFArrayRef (*orig_CNCopySupportedInterfaces)();

static CFArrayRef ja_CNCopySupportedInterfaces() {
    
    CFArrayRef re = NULL;
    
    JAWifiModel *wifi = [JAWifiHook wifiHooked];
    
    if(wifi && wifi.ifnam) {
        NSArray *array = [NSArray arrayWithObject:wifi.ifnam];
        re = CFRetain((__bridge CFArrayRef)(array));
    }
    
    if(!re) {
        re = orig_CNCopySupportedInterfaces();
    }
    
    return re;
}

// CFDictionaryRef CNCopyCurrentNetworkInfo	(CFStringRef interfaceName)
static CFDictionaryRef (*orig_CNCopyCurrentNetworkInfo)(CFStringRef interfaceName);

static CFDictionaryRef ja_CNCopyCurrentNetworkInfo(CFStringRef interfaceName) {
    
    CFDictionaryRef re = NULL;
    
    JAWifiModel *wifi = [JAWifiHook wifiHooked];
    
    if(wifi) {
        NSDictionary *dictionary = @{
                                     @"BSSID" : (wifi.BSSID ? wifi.BSSID : @""),
                                     @"SSID" : (wifi.SSID ? wifi.SSID : @""),
                                     @"SSIDDATA" : (wifi.SSIDDATA ? wifi.SSIDDATA : @""),
                                     };
        re = CFRetain((__bridge CFDictionaryRef)(dictionary));
    }
    
    if(!re) {
        re = orig_CNCopyCurrentNetworkInfo(interfaceName);
    }
    
    return re;
}

// Boolean SCNetworkReachabilityGetFlags(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags *flags)
static Boolean (*orig_SCNetworkReachabilityGetFlags)(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags *flags);

static Boolean ja_SCNetworkReachabilityGetFlags(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags *flags) {
    Boolean re = false;
    
    JAWifiModel *wifi = [JAWifiHook wifiHooked];
    
    if(wifi && wifi.flags > 0) {
        re = true;
        *flags = wifi.flags;
    }
    
    if(!re) {
        re = orig_SCNetworkReachabilityGetFlags(target, flags);
    }
    
    return re;
}

@end
