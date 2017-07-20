//
//  JASwizzler.h
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import <Foundation/Foundation.h>

@interface JASwizzler : NSObject

void JASwizzleMethod(Class self, SEL origSEL, SEL newSEL);

void JASwizzleMethodIMP(Class self, SEL action1, SEL action2, IMP imp);

BOOL JACopyMethod(Class self, Class targetClass, SEL action);

@end
