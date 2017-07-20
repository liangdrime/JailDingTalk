//
//  JALocationHook.m
//  jaildingtalk
//
//  Created by Roylee on 2017/7/17.
//
//

#import "JALocationHook.h"
#import <CoreLocation/CoreLocation.h>
#import <objc/message.h>
#import "JASwizzler.h"
#import "JALocationHelper.h"

#define JAMsgSend4(...) ((void (*)(id, SEL, id, id, SEL, Class))objc_msgSend)(__VA_ARGS__)
#define JAMsgSend5(...) ((void (*)(id, SEL, id, id, id, SEL, Class))objc_msgSend)(__VA_ARGS__)

static NSString * const JASelectorAliasPrefix = @"ja_alias_";

static NSMutableSet *swizzledClasses() {
    static NSMutableSet *set;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        set = [[NSMutableSet alloc] init];
    });
    return set;
}

static SEL JAAliasForSelector(SEL originalSelector) {
    NSString *selectorName = NSStringFromSelector(originalSelector);
    return NSSelectorFromString([JASelectorAliasPrefix stringByAppendingString:selectorName]);
}



@implementation JALocationHook

static Class JASwizzleClassInPlace(Class class) {
    NSString *className = NSStringFromClass(class);
    if (class == nil || className.length == 0) return nil;
    
    // ignore black list class.
    if ([className isEqualToString:@"MKCoreLocationProvider"]) {
        return nil;
    }
    
    @synchronized (swizzledClasses()) {
        if ([swizzledClasses() containsObject:className] == NO) {
            [JALocationHook hook_didUpdateLocations:class];
            [JALocationHook hook_didUpdateToLocation:class];
            [swizzledClasses() addObject:className];
        }
    }
    return class;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get the impletion of method -setDelegate: in class CLLocationManager.
        Class class = NSClassFromString(@"CLLocationManager");
        
        SEL originalSelector = @selector(setDelegate:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        
        // Preserve any existing implementation of -setDelegate:.
        void (*originalInvocation)(id, SEL, id) = NULL;
        if (originalMethod != NULL) {
            originalInvocation = (__typeof__(originalInvocation))method_getImplementation(originalMethod);
        }
        
        // Set up a new invocation of -setDelegate:.
        id newInvocation = ^(id receiver, id delegate) {
            if (originalInvocation == NULL) {
                [receiver doesNotRecognizeSelector:originalSelector];
            }else {
                originalInvocation(receiver, originalSelector, delegate);
                
                // Hook CLLocationManagerDelegate methods of this delegate.
                JASwizzleClassInPlace([delegate class]);
            }
        };
        
        class_replaceMethod(class, originalSelector, imp_implementationWithBlock(newInvocation), "v@:@");
    });
}

+ (void)hook_didUpdateLocations:(Class)class {
    
    SEL didUpdateLocations = @selector(locationManager:didUpdateLocations:);
    
    SEL action = NSSelectorFromString(@"ja_locationManager:didUpdateLocations:action:selfClass:");
    
    if(![class respondsToSelector:action]) {
        JACopyMethod([self class], class, action);
    }
    
    SEL aliasSelector = JAAliasForSelector(didUpdateLocations);
    
    id newInvocation = ^(id self, CLLocationManager *locationManager, NSArray<CLLocation *> *locations) {
        
        // just support instance object, not a class object.
        if (class_isMetaClass(object_getClass(self))) {
            return;
        }
        
        if(strcmp(class_getName(class), class_getName([self class])) != 0) {
            if([class instancesRespondToSelector:aliasSelector]) {
                JAMsgSend4(self, @selector(ja_locationManager:didUpdateLocations:action:selfClass:), locationManager, locations, aliasSelector, class);
            }
        }else {
            JAMsgSend4(self, @selector(ja_locationManager:didUpdateLocations:action:selfClass:), locationManager, locations, aliasSelector, class);
        }
    };
    
    JASwizzleMethodIMP(class, didUpdateLocations, aliasSelector, imp_implementationWithBlock(newInvocation));
}

+ (void)hook_didUpdateToLocation:(Class)class {
    
    SEL didUpdateToLocation = @selector(locationManager:didUpdateToLocation:fromLocation:);
    
    SEL action = NSSelectorFromString(@"ja_locationManager:didUpdateToLocation:fromLocation:action:selfClass:");
    
    if(![class respondsToSelector:action]) {
        JACopyMethod([self class], class, action);
    }
    
    SEL aliasSelector = JAAliasForSelector(didUpdateToLocation);
    
    id newInvocation = ^(id self, CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
        
        // just support instance object, not a class object.
        if (class_isMetaClass(object_getClass(self))) {
            return;
        }
        
        if(strcmp(class_getName(class), class_getName([self class])) != 0) {
            if([class instancesRespondToSelector:aliasSelector]) {
                JAMsgSend5(self, @selector(ja_locationManager:didUpdateToLocation:fromLocation:action:selfClass:), manager, newLocation, oldLocation, aliasSelector, class);
            }
        }else {
            JAMsgSend5(self, @selector(ja_locationManager:didUpdateToLocation:fromLocation:action:selfClass:), manager, newLocation, oldLocation, aliasSelector, class);
        }
    };
    
    JASwizzleMethodIMP(class, didUpdateToLocation, aliasSelector, imp_implementationWithBlock(newInvocation));
}


// Do custom things and call the original selector.
- (void)ja_locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation action:(SEL)action selfClass:(Class)selfClass {
    
    if(!action) {
        return;
    }
    
    CLLocation *_newLocation = [JALocationHelper filteredLocation:newLocation];
    
    if([self respondsToSelector:action]) {
        ((void(*)(id, SEL, id, id, id))objc_msgSend)(self, action, manager, _newLocation, oldLocation);
    }
}

- (void)ja_locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations action:(SEL)action selfClass:(Class)selfClass {
    
    if(!action) {
        return;
    }
    
    NSMutableArray *newLocations = [NSMutableArray arrayWithCapacity:locations.count];
    
    if(locations.count > 0) {
        for (CLLocation *location in locations) {
            [newLocations addObject:[JALocationHelper filteredLocation:location]];
        }
    }
    else {
        [newLocations addObject:[JALocationHelper filteredLocation:nil]];
    }
    
    if([self respondsToSelector:action]) {
        ((void(*)(id, SEL, id, id))objc_msgSend)(self, action, manager, newLocations);
    }
}

@end
