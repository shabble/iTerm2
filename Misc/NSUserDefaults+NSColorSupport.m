//
//  NSUserDefaults+NSColorSupport.m
//  colour-matrix
//
//  Created by shabble on 17/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import "NSUserDefaults+NSColorSupport.h"


@implementation NSUserDefaults (NSColorSupport)

- (void)setColor:(NSColor *)color forKey:(NSString *)key
{
    NSData *colorData = [NSArchiver archivedDataWithRootObject:color];
    [self setObject:colorData forKey:key];
}

- (NSColor *)colorForKey:(NSString *)key
{
    NSColor *color      = nil;
    NSData  *colorData  = [self dataForKey:key];

    if (colorData != nil)
        color = (NSColor *)[NSUnarchiver unarchiveObjectWithData:colorData];
    return color;
}

@end
