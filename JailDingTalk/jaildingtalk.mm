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
#import <objc/message.h>
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
 DTCommonSettingViewController
 DTTableViewDataSource
 DTSectionItem
 DTCellItem
 */
CHDeclareClass(DTCommonSettingViewController)
CHDeclareClass(DTTableViewDataSource);
CHDeclareClass(DTSectionItem);
CHDeclareClass(DTCellItem);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wstrict-prototypes"

/// Show setting
static void ShowLocationSettingController() {
    UIWindow *keyWindow = [JAUntil keyWindow];
    UIViewController *rootViewController = keyWindow.rootViewController;
    
    // present the setting controler.
    JALocationSettingViewController *settingVC = [JALocationSettingViewController new];
    [rootViewController presentViewController:settingVC animated:YES completion:nil];
}

/// Hook setting page, add background keep alive switcher.
CHOptimizedMethod0(self, void, DTCommonSettingViewController, tidyDataSource){
    CHSuper0(DTCommonSettingViewController, tidyDataSource);
    
    // Create the location setting item.
    // `+ (id)cellItemForDefaultStyleWithIcon:(id)arg1 title:(id)arg2 detail:(id)arg3 comment:(id)arg4 showIndicator:(_Bool)arg5 cellDidSelectedBlock:(CDUnknownBlockType)arg6`
    void (^locationSettingClickBlock)(void) = ^() {
        ShowLocationSettingController();
    };
    DTCellItem *(*locationCellMethod)(id, SEL, id, id, id, id, BOOL, id) = (DTCellItem *(*)(id, SEL, id, id, id, id, BOOL, id))objc_msgSend;
    DTCellItem *locationCellItem = locationCellMethod(objc_getClass("DTCellItem"), @selector(cellItemForDefaultStyleWithIcon:title:detail:comment:showIndicator:cellDidSelectedBlock:), nil, @"修改位置", nil, nil, YES,  locationSettingClickBlock);
    
    // Create the location section item.
    // `+ (id)itemWithSectionHeader:(id)arg1 sectionFooter:(id)arg2`
    DTSectionItem *(*locationSectioinMethod)(id, SEL, id, id) = (DTSectionItem *(*)(id, SEL, id, id))objc_msgSend;
    DTSectionItem *sectionItem = locationSectioinMethod(objc_getClass("DTSectionItem"), @selector(itemWithSectionHeader:sectionFooter:), nil, nil);
    [(id)sectionItem setValue:@[locationCellItem] forKey:@"dataSource"];
    
    DTTableViewDataSource *dataSource = [(id)self valueForKey:@"dataSource"];
    NSString *tableDataSourceKey= @"tableViewDataSource";
    NSMutableArray *mutableData = [[(id)dataSource valueForKey:tableDataSourceKey] mutableCopy];
    if ([mutableData count] > 3) {
        [mutableData insertObject:sectionItem atIndex:4]; // add behind calendar setting.
    } else {
        [mutableData addObject:sectionItem];
    }
    
    [(id)dataSource setValue:mutableData forKey:tableDataSourceKey];
}

/*
 // Add new method of click map setting
 CHDeclareMethod1(void, DTCommonSettingViewController, locationSettingClick, id, sender){
 
 }
 */

CHConstructor {
    @autoreleasepool {
        CHLoadLateClass(DTCommonSettingViewController);
        CHLoadLateClass(DTTableViewDataSource);
        CHLoadLateClass(DTSectionItem);
        CHLoadLateClass(DTCellItem);
        CHHook0(DTCommonSettingViewController, tidyDataSource);
    }
}

#pragma clang diagnostic pop
