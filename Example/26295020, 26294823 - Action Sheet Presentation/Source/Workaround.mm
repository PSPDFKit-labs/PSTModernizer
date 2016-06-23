//
//  Workaround.m
//  PresentationPlayground
//
//  Created by Peter Steinberger on 16/05/16.
//

#import "Workaround.h"
#import <UIKit/UIKit.h>
#import <objc/message.h>

static IMP pspdf_swizzleSelector(Class clazz, SEL selector, IMP newImplementation) {
    NSCParameterAssert(clazz);
    NSCParameterAssert(selector);
    NSCParameterAssert(newImplementation);

    // If the method does not exist for this class, do nothing.
    const Method method = class_getInstanceMethod(clazz, selector);
    if (!method) {
        NSLog(@"%@ doesn't exist in %@.", NSStringFromSelector(selector), NSStringFromClass(clazz));
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

IMP pspdf_swizzleSelectorWithBlock(Class clazz, SEL selector, id newImplementationBlock) {
    IMP const newImplementation = imp_implementationWithBlock(newImplementationBlock);
    return pspdf_swizzleSelector(clazz, selector, newImplementation);
}

FOUNDATION_EXPORT void PSPDFInstallWorkaroundForSheetPresentation(void) {
    __block auto removeWorkaround = ^{};
    const auto installWorkaround = ^{
        const SEL presentSEL = @selector(presentViewController:animated:completion:);
        __block IMP origIMP = pspdf_swizzleSelectorWithBlock(UIViewController.class, presentSEL, ^(UIViewController *self, id vC, BOOL animated, id completion) {
            UIViewController *targetVC = self;
            while (targetVC.presentedViewController) {
                targetVC = targetVC.presentedViewController;
            }
            ((void (*)(id, SEL, id, BOOL, id))origIMP)(targetVC, presentSEL, vC, animated, completion);
        });
        removeWorkaround = ^{
            pspdf_swizzleSelector(UIViewController.class, presentSEL, origIMP);
        };
    };

    // Fixes rdar:// <TODO>
    const SEL presentSheetSEL = NSSelectorFromString(@"presentSheetFromRect:");
    const auto swizzleOnClass = ^(Class klass) {
        const __block IMP origIMP = pspdf_swizzleSelectorWithBlock(klass, presentSheetSEL, ^(id self, CGRect rect) {
            // Before calling the original implementation, we swizzle the presentation logic on UIViewController
            installWorkaround();
            // UIKit later presents the sheet on [view.window rootViewController];
            // Our workaround forwards this to the topmost presentedViewController instead.
            ((void (*)(id, SEL, CGRect))origIMP)(self, presentSheetSEL, rect);
            // Cleaning up again - this workaround would swallow bugs if we let it be there.
            removeWorkaround();
        });
    };
    swizzleOnClass(NSClassFromString(@"_UIRotatingAlertController"));
    swizzleOnClass(NSClassFromString(@"WKActionSheet"));
}
