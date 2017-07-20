//
//  jaildingtalk.mm
//  jaildingtalk
//
//  Created by Roylee on 2017/7/16.
//  Copyright (c) 2017年 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import "JALocationHook.h"
#import "UIBarButtonItem+JABlock.h"
#import "JALocationSettingViewController.h"
#import "JAUntil.h"

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

/*
 DTContainerAppDelegate
 DTTabBarController
 */
CHDeclareClass(DTSettingViewController);


/// Show setting
static void ShowLocationSettingController() {
    UIWindow *keyWindow = [JAUntil keyWindow];
    UIViewController *rootViewController = keyWindow.rootViewController;
    
    // present the setting controler.
    JALocationSettingViewController *settingVC = [JALocationSettingViewController new];
    [rootViewController presentViewController:settingVC animated:YES completion:nil];
}

/// User center.
CHOptimizedMethod0(self, void, DTSettingViewController, viewDidLoad) {
    CHSuper0(DTSettingViewController, viewDidLoad);
    
    // Add left location setting button.
    UIBarButtonItem *leftBarItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"nav_location_setting"] action:^(UIBarButtonItem *sender) {
        ShowLocationSettingController();
    }];
    UIViewController *_self = (UIViewController *)self;
    _self.navigationItem.leftBarButtonItem = leftBarItem;
}

CHConstructor {
    @autoreleasepool {
        CHLoadLateClass(DTSettingViewController);
        CHHook0(DTSettingViewController, viewDidLoad);
    }
}

