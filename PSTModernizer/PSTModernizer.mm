//
//  PSTModernizer.mm
//  PSTModernizer
//
//  Created by Peter Steinberger on 23/06/16.
//  Copyright © 2016 PSPDFKit GmbH. All rights reserved.
//

#import "PSTModernizer.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <pthread.h>

// Hello, Swift :)
#if defined(__cplusplus)
#define let const auto
#else
// Works as of Xcode 8
#define let const __auto_type
#endif

#define PSTClassObfuscate(...) NSClassFromString([NSString stringWithFormat:__VA_ARGS__])
#define PSTSELObfuscate(...) NSSelectorFromString([NSString stringWithFormat:__VA_ARGS__])

// iOS 10 compatibility
#ifndef kCFCoreFoundationVersionNumber_iOS_10_0
#define kCFCoreFoundationVersionNumber_iOS_10_0 1300.0
#endif

#define PST_IS_IOS10_0_OR_GREATER (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_10_0)

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#define PST_IF_IOS10_0_OR_GREATER(...) \
if (PST_IS_IOS10_0_OR_GREATER) { \
PST_PARTIAL_AVAILABILITY_BEGIN \
__VA_ARGS__ \
PST_PARTIAL_AVAILABILITY_END }
#else
#define PST_IF_IOS10_0_OR_GREATER(...)
#endif

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED < 100000
#define PST_IF_PRE_IOS10_0(...)  \
if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_10_0) { \
PST_PARTIAL_AVAILABILITY_BEGIN \
__VA_ARGS__ \
PST_PARTIAL_AVAILABILITY_END }
#else
#define PST_IF_PRE_IOS10_0(...)
#endif

#define PSTLogError NSLog
#define PSTLogWarning NSLog

@implementation PSTModernizer

+ (double)version {
    return 1000.0;
}

+ (void)installModernizer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self installModernizerOnce];
    });
}

+ (void)installModernizerOnce {
    // Define this class in the runtime to block the modernizer being called.
    if (NSClassFromString(@"PSTModernizerDisabled")) {
        return;
    }

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED < 100000

    // Fixes rdar://26295020: Action sheets presented for links don’t work in presented view controllers.
    // This has been fixed in iOS 10b1.
    PSTInstallWorkaroundForSheetPresentationRdar26295020();

    // UIImage has threading issues under iOS 9.
    // See https://github.com/AFNetworking/AFNetworking/issues/2572#issuecomment-227895102
    // This has been fixed in iOS 10b1
    PSTAddLockingToUIImageRdar26954460();

#endif

    // In anticipation that we'll find bugs in iOS 10 that we run as well, not everything is blocked when you compile with iOS 10 only.
    NSLog(@"%@ version %.0f installed.", NSStringFromClass(self.class), self.version);
}

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED < 100000

static void PSTInstallWorkaroundForSheetPresentationRdar26295020() {
    // This has been fixed in iOS 10b1 so it's only necessary for older versions of iOS.
    PST_IF_IOS10_0_OR_GREATER(return;)

    __block auto removeWorkaround = ^{};
    let installWorkaround = ^{
        let presentSEL = @selector(presentViewController:animated:completion:);
        const __block IMP origIMP = pst_swizzleSelectorWithBlock(UIViewController.class, presentSEL, ^(UIViewController *_self, id vC, BOOL animated, id completion) {
            while (_self.presentedViewController) {
                _self = _self.presentedViewController;
            }
            ((void (*)(id, SEL, id, BOOL, id))origIMP)(_self, presentSEL, vC, animated, completion);
        });
        if (origIMP) {
            removeWorkaround = ^{
                pst_swizzleSelector(UIViewController.class, presentSEL, origIMP);
            };
        }
    };

    let presentSheetSEL = PSTSELObfuscate(@"present%@FromRect:", @"Sheet");
    let swizzleOnClass = ^(Class klass) {
        if (!klass) {
            PSTLogWarning(@"Unable to install workaround for rdar://26295020.");
            return;
        }
        __block IMP origIMP = pst_swizzleSelectorWithBlock(klass, presentSheetSEL, ^(id _self, CGRect rect) {
            // Before calling the original implementation, we swizzle the presentation logic on UIViewController
            installWorkaround();
            // UIKit later presents the sheet on [view.window rootViewController];
            // See https://github.com/WebKit/webkit/blob/1aceb9ed7a42d0a5ed11558c72bcd57068b642e7/Source/WebKit2/UIProcess/ios/WKActionSheet.mm#L102
            // Our workaround forwards this to the topmost presentedViewController instead.
            ((void (*)(id, SEL, CGRect))origIMP)(_self, presentSheetSEL, rect);
            // Cleaning up again - this workaround would swallow bugs if we let it be there.
            removeWorkaround();
        });
    };
    swizzleOnClass(PSTClassObfuscate(@"_%@%@AlertController", @"UI", @"Rotating"));

    // WKWebView might not be loaded, then we can't patch it.
    if (let wkWebViewClass = PSTClassObfuscate(@"%@ActionSheet", @"WK")) {
        swizzleOnClass(wkWebViewClass);
    }
}

static void PSTAddLockingToUIImageRdar26954460() {
    // This has been fixed in iOS 10b1 so it's only necessary for older versions of iOS.
    PST_IF_IOS10_0_OR_GREATER(return;)

    // The dictionary that UITraitCollectionCacheForBuiltinStorage returns
    // is not thread safe. We can't easily hook C methods, so we lock the main initializer
    // where the cache is being used. This will not cover all races around UITraitCollection,
    // however with this level of granularity UIImage creation will work as expected.
    //
    // Overriding all calls of UITraitCollectionCacheForBuiltinStorage would require
    // using private API.

    static pthread_mutex_t mutex = PTHREAD_RECURSIVE_MUTEX_INITIALIZER;
    let displayScaleSEL = @selector(traitCollectionWithDisplayScale:);
    __block IMP origIMP = pst_swizzleSelectorWithBlock(object_getClass(UITraitCollection.class), displayScaleSEL, ^id(id _self, CGFloat scale) {
        pthread_mutex_lock(&mutex);
        id result = ((id (*)(id, SEL, CGFloat))origIMP)(_self, displayScaleSEL, scale);
        pthread_mutex_unlock(&mutex);
        return result;
    });
}

#endif

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Swizzle

static IMP pst_swizzleSelectorWithBlock(Class clazz, SEL selector, id newImplementationBlock) {
    const IMP newImplementation = imp_implementationWithBlock(newImplementationBlock);
    return pst_swizzleSelector(clazz, selector, newImplementation);
}

static IMP pst_swizzleSelector(Class clazz, SEL selector, IMP newImplementation) {
    NSCParameterAssert(clazz);
    NSCParameterAssert(selector);
    NSCParameterAssert(newImplementation);

    // If the method does not exist for this class, do nothing.
    Method method = class_getInstanceMethod(clazz, selector);
    if (!method) {
        PSTLogError(@"%@ doesn't exist in %@.", NSStringFromSelector(selector), NSStringFromClass(clazz));
        // Cannot swizzle methods which are not implemented by the class or one of its parents.
        return NULL;
    }

    // Make sure the class implements the method. If this is not the case, inject an implementation, only calling 'super'.
    const char *types = method_getTypeEncoding(method);

    @synchronized (clazz) {
        // class_addMethod will simply return NO if the method is already implemented.
#if !defined(__arm64__)
        // Sufficiently large struct
        typedef struct LargeStruct_ {
            char dummy[16];
        } LargeStruct;

        NSUInteger retSize = 0;
        NSGetSizeAndAlignment(types, &retSize, NULL);

        // Large structs on 32-bit architectures
        if (sizeof(void *) == 4 && types[0] == _C_STRUCT_B && retSize != 1 && retSize != 2 && retSize != 4 && retSize != 8) {
            class_addMethod(clazz, selector, imp_implementationWithBlock(^(__unsafe_unretained id self, va_list argp) {
                struct objc_super super = {.receiver = self, .super_class = class_getSuperclass(clazz)};
                return ((LargeStruct (*)(struct objc_super *, SEL, va_list))objc_msgSendSuper_stret)(&super, selector, argp);
            }), types);
        }
        // All other cases
        else {
#endif
            class_addMethod(clazz, selector, imp_implementationWithBlock(^(__unsafe_unretained id self, va_list argp) {
                struct objc_super super = {.receiver = self, .super_class = class_getSuperclass(clazz)};
                return ((id (*)(struct objc_super *, SEL, va_list))objc_msgSendSuper)(&super, selector, argp);
            }), types);
#if !defined(__arm64__)
        }
#endif
        // Swizzling
        return class_replaceMethod(clazz, selector, newImplementation, types);
    }
}

@end
