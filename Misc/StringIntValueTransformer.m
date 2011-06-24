/* -*- mode:objc -*-
 **
 **  StringIntValueTransformer.m
 **
 **  Copyright (c) 2011
 **
 **  Author: Tom Feist
 **
 **  Project: iTerm2
 **
 **  Description: A ValueTransformer for converting a string into its
 **               integer (via NSNumber) value, and back again.
 **
 **  This program is free software; you can redistribute it and/or modify
 **  it under the terms of the GNU General Public License as published by
 **  the Free Software Foundation; either version 2 of the License, or
 **  (at your option) any later version.
 **
 **  This program is distributed in the hope that it will be useful,
 **  but WITHOUT ANY WARRANTY; without even the implied warranty of
 **  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 **  GNU General Public License for more details.
 **
 **  You should have received a copy of the GNU General Public License
 **  along with this program; if not, write to the Free Software
 **  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


#import <Foundation/Foundation.h>
#import "StringIntValueTransformer.h"

@implementation StringIntValueTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    if (value == nil) {
        return [NSNumber numberWithInt:0];
    }

    if (![value respondsToSelector: @selector(integerValue)]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Value does not respond to -integerValue. (Value is %@)",
                     [value class]];
    }

    return [NSNumber numberWithInteger:[value integerValue]];
}

- (id)reverseTransformedValue:(id)value
{
    if (value == nil) {
        return @"";   
    }

    if (![value respondsToSelector: @selector(stringValue)]) {
        [NSException raise:NSInternalInconsistencyException 
                    format:@"Value does not respond to -stringValue. (Value is %@)",
                     [value class]];
    }

    return [NSString stringWithString:[value stringValue]];
}

@end
