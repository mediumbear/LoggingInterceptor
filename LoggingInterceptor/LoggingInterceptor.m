//
//  LoggingInterceptor.m
//
//  Created by Edward Povazan on 12-07-13.
//  Copyright (c) 2012 Edward Povazan. All rights reserved.
//


#import <objc/runtime.h>

/*
    Instructions:

    1. Drag and drop this LoggingInterceptor.m file anywhere into your project, make sure the copy option is selected.

    2. DON'T FORGET THIS STEP, OR RISK REJECTION ON THE APP STORE!
    2.1 In the "Build Settings" view, press "Add Build Setting/Add User Defined Setting"
    2.2 Enter the following setting name: EXCLUDED_SOURCE_FILE_NAMES
    2.3 In the "Release" line, add LoggingInterceptor.m

    3. Run your app and look at what is logged. Add or comment out lines in the +load methods as needed.
 */

// Intercept a no-arg message.
#define INTERCEPTOR_METHOD(methodName) - (void)methodName ## Interceptor { [self logInterceptedSelector:_cmd]; [self methodName ## Interceptor]; }
// Intercept a 1 arg message. The arg must be an object type.
#define INTERCEPTOR_METHOD1(methodName, type, arg) - (void)methodName ## Interceptor:(type)arg { [self logInterceptedSelector:_cmd message:[arg description]]; [self methodName ## Interceptor:arg]; }
// Intercept a BOOL arg message.
#define INTERCEPTOR_METHOD1b(methodName, type, arg) - (void)methodName ## Interceptor:(type)arg { [self logInterceptedSelector:_cmd message:[NSString stringWithFormat:@"%s", arg ? "YES" : "NO"]]; [self methodName ## Interceptor:arg]; }
// Intercept a integer arg message.
#define INTERCEPTOR_METHOD1i(methodName, type, arg) - (void)methodName ## Interceptor:(type)arg { [self logInterceptedSelector:_cmd message:[NSString stringWithFormat:@"%d", arg]]; [self methodName ## Interceptor:arg]; }
// Intercept a float arg message.
#define INTERCEPTOR_METHOD1f(methodName, type, arg) - (void)methodName ## Interceptor:(type)arg { [self logInterceptedSelector:_cmd message:[NSString stringWithFormat:@"%.3f", arg]]; [self methodName ## Interceptor:arg]; }
// Used within -load to inject the interceptor.
#define INJECT_INTERCEPTOR(selectorName) intercept([self class], @selector(selectorName));


static NSString *const kInterceptMessagePrefix = @"*** Intercept ";


static void checkInterception(Class class, SEL selector, Method method) {
    if (method == NULL) {
        NSLog(@"Failed to intercept [%@ %@]", NSStringFromClass(class), NSStringFromSelector(selector));
        exit(EXIT_FAILURE);
    }
}

static void intercept(Class class, SEL selector) {
    Method intercept = class_getInstanceMethod(class, selector);
    checkInterception(class, selector, intercept);

    // Make the correct selector name for the interceptor. Depends on if it is a keyword method or not.
    NSString *selectorName = NSStringFromSelector(selector);
    NSString *suffix = [selectorName substringFromIndex:selectorName.length - 1];
    if ([suffix isEqualToString:@":"]) {
        selectorName = [selectorName substringToIndex:selectorName.length - 1];
        selectorName = [NSString stringWithFormat:@"%@Interceptor:", selectorName];
    } else {
        selectorName = [NSString stringWithFormat:@"%@Interceptor", selectorName];
    }

    SEL interceptSelector = NSSelectorFromString(selectorName);
    Method interceptor = class_getInstanceMethod(class, interceptSelector);
    checkInterception(class, selector, interceptor);

    method_exchangeImplementations(intercept, interceptor);
}


@implementation NSObject (LoggingInterceptor)

- (void)logInterceptedSelector:(SEL)selector {
    NSLog(@"%@-[%@ %@]", kInterceptMessagePrefix, NSStringFromClass([self class]), NSStringFromSelector(selector));
}

- (void)logInterceptedSelector:(SEL)selector message:(NSString *)message {
    NSLog(@"%@-[%@ %@] %@", kInterceptMessagePrefix, NSStringFromClass([self class]), NSStringFromSelector(selector), message);
}

@end


@implementation UIViewController (LoggingInterceptor)

+ (void)load {
    @autoreleasepool {
        INJECT_INTERCEPTOR(viewDidLoad);
        INJECT_INTERCEPTOR(viewDidAppear:);
        INJECT_INTERCEPTOR(removeFromParentViewController);
        INJECT_INTERCEPTOR(willMoveToParentViewController:);
        INJECT_INTERCEPTOR(didMoveToParentViewController:);
    }
}

INTERCEPTOR_METHOD(viewDidLoad)
INTERCEPTOR_METHOD1b(viewDidAppear, BOOL, animated)
INTERCEPTOR_METHOD(removeFromParentViewController);
INTERCEPTOR_METHOD1(willMoveToParentViewController, UIViewController *, parent)
INTERCEPTOR_METHOD1(didMoveToParentViewController, UIViewController *, parent)

@end


@implementation UIControl (LoggingInterceptor)

+ (void)load {
    @autoreleasepool {
        intercept([UIControl class], @selector(sendAction:to:forEvent:));
    }
}

- (void)sendAction:(SEL)action to:(id)target forEventInterceptor:(UIEvent *)event {
    NSLog(@"%@-[%@ sendAction:%@ to:%@ forEvent:]", kInterceptMessagePrefix, NSStringFromClass([self class]), NSStringFromSelector(action), NSStringFromClass([target class]));
    [self sendAction:action to:target forEventInterceptor:event];
}


@end