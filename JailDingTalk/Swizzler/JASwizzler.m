//
//  JASwizzler.m
//  jaildingtalk
//
//  Created by Roylee on 2017/7/18.
//
//

#import "JASwizzler.h"
#import <objc/runtime.h>

@implementation JASwizzler

void JASwizzleMethod(Class self, SEL origSEL, SEL newSEL) {
    NSCParameterAssert(self);
    NSCParameterAssert(origSEL);
    NSCParameterAssert(newSEL);
    
    Method origMethod = class_getInstanceMethod(self, origSEL);
    Method newMethod = nil;
    if (!origMethod) {
        origMethod = class_getClassMethod(self, origSEL);
        newMethod = class_getClassMethod(self, newSEL);
    }else{
        newMethod = class_getInstanceMethod(self, newSEL);
    }
    
    if (!origMethod || !newMethod) {
        return;
    }
    
    if(class_addMethod(self, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(self, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
    }
}

void JASwizzleMethodIMP(Class self, SEL action1, SEL action2, IMP imp) {
    NSCParameterAssert(self);
    NSCParameterAssert(action1);
    NSCParameterAssert(action2);
    NSCParameterAssert(imp);
    
    Method targetMethod = class_getInstanceMethod(self, action1);
    const char *typeEncoding = NULL;
    if (targetMethod == NULL) {
        typeEncoding = JASignatureForUndefinedSelector(action1);;
    }else {
        typeEncoding = method_getTypeEncoding(class_getInstanceMethod(self, action1));
    }
    JACheckTypeEncoding(typeEncoding);
    
    if (class_addMethod(self, action2, imp, typeEncoding)) {
        JASwizzleMethod(self, action2, action1);
    }
}

BOOL JACopyMethod(Class self, Class targetClass, SEL action) {
    NSCParameterAssert(self);
    NSCParameterAssert(targetClass);
    NSCParameterAssert(action);
    
    Method method = class_getInstanceMethod(self, action);
    
    if(!method) {
        NSLog(@"origMethod is null");
        return NO;
    }
    
    return class_addMethod(targetClass, action, method_getImplementation(method), method_getTypeEncoding(method));
}

static const char *JASignatureForUndefinedSelector(SEL selector) {
    const char *name = sel_getName(selector);
    NSMutableString *signature = [NSMutableString stringWithString:@"v@:"];
    
    while ((name = strchr(name, ':')) != NULL) {
        [signature appendString:@"@"];
        name++;
    }
    
    return signature.UTF8String;
}

// It's hard to tell which struct return types use _objc_msgForward, and
// which use _objc_msgForward_stret instead, so just exclude all struct, array,
// union, complex and vector return types.
static void JACheckTypeEncoding(const char *typeEncoding) {
#if !NS_BLOCK_ASSERTIONS
    // Some types, including vector types, are not encoded. In these cases the
    // signature starts with the size of the argument frame.
    NSCAssert(*typeEncoding < '1' || *typeEncoding > '9', @"unknown method return type not supported in type encoding: %s", typeEncoding);
    NSCAssert(strstr(typeEncoding, "(") != typeEncoding, @"union method return type not supported");
    NSCAssert(strstr(typeEncoding, "{") != typeEncoding, @"struct method return type not supported");
    NSCAssert(strstr(typeEncoding, "[") != typeEncoding, @"array method return type not supported");
    NSCAssert(strstr(typeEncoding, @encode(_Complex float)) != typeEncoding, @"complex float method return type not supported");
    NSCAssert(strstr(typeEncoding, @encode(_Complex double)) != typeEncoding, @"complex double method return type not supported");
    NSCAssert(strstr(typeEncoding, @encode(_Complex long double)) != typeEncoding, @"complex long double method return type not supported");
    
#endif // !NS_BLOCK_ASSERTIONS
}

@end
