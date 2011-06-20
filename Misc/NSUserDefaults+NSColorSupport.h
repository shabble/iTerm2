//
//  NSUserDefaults+NSColorSupport.h
//  colour-matrix
//
//  Created by shabble on 17/06/2011.
//  Copyright 2011 . All rights reserved.
//  Code from:
//  http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/DrawColor/Tasks/StoringNSColorInDefaults.html
//

#import <Cocoa/Cocoa.h>


@interface NSUserDefaults (NSColorSupport)

- (void)setColor:(NSColor *)color forKey:(NSString *)key;
- (NSColor *)colorForKey:(NSString *)key;

@end
