/* -*- mode:objc -*-
 **
 **  PreferencesMigrator.m
 **
 **  Copyright (c) 2011
 **
 **  Author: Tom Feist
 **
 **  Project: iTerm2
 **
 **  Description: Implements a set of helper functions for determining which
 **               version of iTerm config file exists, and updating it to the
 **               latest version.
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

#import "PreferencesMigrator.h"

@implementation PreferencesMigrator

/*
 Static method to copy old preferences file, iTerm.plist or net.sourceforge.iTerm.plist, to new
 preferences file, com.googlecode.iterm2.plist
 */

+ (BOOL) migratePreferences {

    NSString *prefDir = [[[NSHomeDirectory()
    stringByAppendingPathComponent:@"tmp"]
    stringByAppendingPathComponent:@"Library"]
    stringByAppendingPathComponent:@"Preferences"];

    NSString *reallyOldPrefs = [prefDir stringByAppendingPathComponent:@"iTerm.plist"];
    NSString *somewhatOldPrefs = [prefDir stringByAppendingPathComponent:@"net.sourceforge.iTerm.plist"];
    NSString *newPrefs = [prefDir stringByAppendingPathComponent:@"com.googlecode.iterm2.plist"];

    NSFileManager *mgr = [NSFileManager defaultManager];

    if ([mgr fileExistsAtPath:newPrefs]) {
        return NO;
    }
    NSString* source;
    if ([mgr fileExistsAtPath:somewhatOldPrefs]) {
        source = somewhatOldPrefs;
    } else if ([mgr fileExistsAtPath:reallyOldPrefs]) {
        source = reallyOldPrefs;
    } else {
        return NO;
    }

    NSLog(@"Preference file migrated");
    [mgr copyPath:source toPath:newPrefs handler:nil];
    [NSUserDefaults resetStandardUserDefaults];
    return YES;
}
 
@end
