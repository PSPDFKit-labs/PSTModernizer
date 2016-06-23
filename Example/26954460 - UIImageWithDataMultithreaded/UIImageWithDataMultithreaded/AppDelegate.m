//
//  AppDelegate.m
//  UIImageWithDataMultithreaded
//
//  Created by Peter Steinberger on 22/06/16.
//  Copyright © 2016 PSPDFKit GmbH. All rights reserved.
//

#import "AppDelegate.h"
#import "PSTModernizer.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [PSTModernizer installModernizer];
    return YES;
}

@end
