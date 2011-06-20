// -*- mode:objc -*-
// $Id: iTermApplicationDelegate.h,v 1.21 2006-11-21 19:24:29 yfabian Exp $
/*
 **  iTermApplicationDelegate.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **      Initial code by Kiichi Kusama
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

//#define GENERAL_VERBOSE_LOGGING
#ifdef GENERAL_VERBOSE_LOGGING
#define DLog NSLog
#else
#define DLog(args...) \
do { \
if (gDebugLogging) { \
DebugLog([NSString stringWithFormat:args]); \
} \
} while (0)
#endif

@class PseudoTerminal;
extern BOOL gDebugLogging;
void DebugLog(NSString* value);

@interface iTermAboutWindow : NSPanel
{
}

- (IBAction)closeCurrentSession:(id)sender;

@end

@interface iTermApplicationDelegate : NSObject
{
    // about window
    NSWindowController *aboutController;
    IBOutlet id ABOUT;
    IBOutlet NSTextView *AUTHORS;
/*    
    // Menu items
    IBOutlet NSMenu     *bookmarkMenu;
    IBOutlet NSMenuItem *selectTab;
    IBOutlet NSMenuItem *previousTerminal;
    IBOutlet NSMenuItem *nextTerminal;
    IBOutlet NSMenuItem *logStart;
    IBOutlet NSMenuItem *logStop;
    IBOutlet NSMenuItem *closeTab;
    IBOutlet NSMenuItem *closeWindow;
    IBOutlet NSMenuItem *sendInputToAllSessions;
    IBOutlet NSMenuItem *toggleBookmarksView;
    IBOutlet NSMenuItem *irNext;
    IBOutlet NSMenuItem *irPrev;
*/
    IBOutlet NSMenuItem *secureInput;
    IBOutlet NSMenuItem *useTransparency;
    IBOutlet NSMenuItem *maximizePane;
    BOOL secureInputDesired_;
    BOOL quittingBecauseLastWindowClosed_;

    NSDate* launchTime_;

}

- (void)awakeFromNib;

// NSApplication Delegate methods
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;
- (BOOL)applicationShouldTerminate: (NSNotification *) theNotification;
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;

//- (NSMenu*)bookmarksMenu;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app;

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag;

- (void)applicationDidBecomeActive:(NSNotification *)aNotification;
- (void)applicationDidResignActive:(NSNotification *)aNotification;


- (IBAction)debugLogging:(id)sender;

    // About window
- (IBAction)showAbout:(id)sender;
- (IBAction)showPrefWindow:(id)sender;

// Notifications
- (void)reloadMenus: (NSNotification *) aNotification;
- (void)nonTerminalWindowBecameKey: (NSNotification *) aNotification;

// font control

@end
