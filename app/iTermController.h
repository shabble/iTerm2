// -*- mode:objc -*-
// $Id: iTermController.h,v 1.29 2008-10-08 05:54:50 yfabian Exp $
/*
 **  iTermController.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **          Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: Implements the main application delegate and handles the addressbook functions.
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

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class PseudoTerminal;
@class PTYTextView;
@class GTMCarbonHotKey;

@interface iTermController : NSObject
{


    // App-wide hotkey
    int hotkeyCode_;
    int hotkeyModifiers_;

    GTMCarbonHotKey* carbonHotKey_;

    CFMachPortRef machPortRef;
    CFRunLoopSourceRef eventSrc;
    int keyWindowIndexMemo_;
    BOOL itermWasActiveWhenHotkeyOpened;
    BOOL rollingIn_;
}

+ (iTermController*)sharedInstance;
+ (void)sharedInstanceRelease;

+ (void)switchToSpaceInBookmark:(NSDictionary*)aDict;
- (BOOL)rollingInHotkeyTerm;


- (void)stopEventTap;

- (NSArray*)sortedEncodingList;
- (BOOL)eventIsHotkey:(NSEvent*)e;
- (void)unregisterHotkey;
- (BOOL)haveEventTap;
- (BOOL)registerHotkey:(int)keyCode modifiers:(int)modifiers;
- (void)beginRemappingModifiers;

@end

