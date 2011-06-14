/*
 **  ProfilesWindow.h (was BookmarksWindow.h)
 **
 **  Created by George Nachman on 8/29/10.
 **  Project: iTerm2
 **
 **  Description: Display a window with searchable profiles. You can use this
 **    to open profiles in a new window or tab.
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
 */

#import <Cocoa/Cocoa.h>
#import "ProfilesListView.h"

@interface ProfilesWindow : NSWindowController <ProfilesTableDelegate> {
    IBOutlet ProfilesListView* tableView_;
    IBOutlet NSSegmentedControl* actions_;
    IBOutlet NSButton* horizontalPaneButton_;
    IBOutlet NSButton* verticalPaneButton_;
    IBOutlet NSButton* tabButton_;
    IBOutlet NSButton* windowButton_;
	IBOutlet NSButton* closeAfterOpeningProfile_;
	IBOutlet NSButton* newTabsInNewWindowButton_;
}

+ (ProfilesWindow*)sharedInstance;

- (id)init;
- (id)initWithWindowNibName:(NSString*)windowNibName;
/*- (IBAction)openProfileInHorizontalPane:(id)sender;
- (IBAction)openProfileInVerticalPane:(id)sender;
- (IBAction)openProfileInTab:(id)sender;
- (IBAction)openProfileInWindow:(id)sender;
 */
- (void)profileTableSelectionDidChange:(id)profileTable;
- (void)profileTableSelectionWillChange:(id)profileTable;
- (void)profileTableRowSelected:(id)profileTable;
- (NSMenu*)profilesTable:(id)profileTable menuForEvent:(NSEvent*)theEvent;

- (IBAction)editProfiles:(id)sender;
- (IBAction)closeAfterOpeningChanged:(id)sender;
//- (IBAction)newTabsInNewWindow:(id)sender;

// NSWindow Delegate
- (void)windowDidBecomeKey:(NSNotification *)notification;

@end
