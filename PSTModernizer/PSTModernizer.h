//
//  PSTModernizer.h
//  PSTModernizer
//
//  Created by Peter Steinberger on 23/06/16.
//  Copyright © 2016 PSPDFKit GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Patches the runtime as soon as this class is linked within the `load` path.
@interface PSTModernizer : NSObject

/// Call this early enough - ideally in your AppDelegate.
+ (void)installModernizer;

/// Returns the version of the modernizer.
+ (double)version;

@end
