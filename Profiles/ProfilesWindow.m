/*
**  BookmarksWindow.m
**  iTerm
**
**  Created by George Nachman on 8/29/10.
**  Project: iTerm
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

#import "ProfilesWindow.h"
#import "Profiles/ProfileModel.h"
#import "App/iTermController.h"
#import "Prefs/PreferencePanelController.h"

typedef enum {
    HORIZONTAL_PANE,
    VERTICAL_PANE,
    NO_PANE // no gane
} PaneMode;

@implementation ProfilesWindow

+ (ProfilesWindow*)sharedInstance
{
    static ProfilesWindow* instance;
    if (!instance) {
        instance = [[ProfilesWindow alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [self initWithWindowNibName:@"BookmarksWindow"];
    return self;
}

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (!self) {
        return nil;
    }

    // Force the window to load
    [self window];
    [[self window] setDelegate:self];
    [[self window] setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace];
    [tableView_ setDelegate:self];
    [tableView_ allowMultipleSelections];
    [tableView_ multiColumns];

    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSNumber* n = [prefs objectForKey:@"CloseBookmarksWindowAfterOpening"];
    [closeAfterOpeningProfile_ setState:[n boolValue] ? NSOnState : NSOffState];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePaneButtons:)
                                                 name:@"iTermWindowBecameKey"
                                               object:nil];

    return self;
}




- (void)updatePaneButtons:(id)sender
{
    [self profileTableSelectionDidChange:tableView_];
}


- (void)profileTableSelectionDidChange:(id)profileTable
{
    NSSet* guids = [tableView_ selectedGuids];
    if ([guids count]) {
        BOOL windowExists = NO; //[[iTermController sharedInstance] currentTerminal] != nil;
        [horizontalPaneButton_ setEnabled:windowExists];
        [verticalPaneButton_ setEnabled:windowExists];
        // tabButton is enabled even if windowExists==false because its shortcut is enter and we
        // don't want to break that.
        [tabButton_ setEnabled:YES];
        [windowButton_ setEnabled:YES];
        if ([guids count] > 1) {
            [newTabsInNewWindowButton_ setEnabled:YES];
        } else {
            [newTabsInNewWindowButton_ setEnabled:NO];
        }
    } else {
        [horizontalPaneButton_ setEnabled:NO];
        [verticalPaneButton_ setEnabled:NO];
        [tabButton_ setEnabled:NO];
        [windowButton_ setEnabled:NO];
    }
    for (int i = 0; i < 2; ++i) {
        [actions_ setEnabled:([guids count] > 0) forSegment:i];
    }
}

- (void)profileTableSelectionWillChange:(id)profileTable
{
}

- (void)profileTableRowSelected:(id)profileTable
{
    NSSet* guids = [tableView_ selectedGuids];
    for (NSString* guid in guids) {
        //PseudoTerminal* terminal = [[iTermController sharedInstance] currentTerminal];
        //Profile* profile = [[ProfileModel sharedInstance] profileWithGuid:guid];
       // [[iTermController sharedInstance] launchProfile:profile
       //                                       inTerminal:terminal];
    }
    if ([closeAfterOpeningProfile_ state] == NSOnState) {
        [[self window] close];
    }
}

- (IBAction)editProfiles:(id)sender
{
    [[PreferencePanelController sharedInstance] run];
    [[PreferencePanelController sharedInstance] showProfiles];
}

- (IBAction)editSelectedProfile:(id)sender
{
    NSString* guid = [tableView_ selectedGuid];
    if (guid) {
        [[PreferencePanelController sharedInstance] openToProfile:guid];
    }
}

- (NSMenu*)profilesTable:(id)profileTable menuForEvent:(NSEvent*)theEvent
{
    NSMenu* menu =[[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];

    int count = [[profileTable selectedGuids] count];
    if (count == 1) {
        [menu addItemWithTitle:@"Edit Profile..."
                        action:@selector(editSelectedProfile:)
                 keyEquivalent:@""];
        [menu addItemWithTitle:@"Open in New Tab"
                        action:@selector(openProfileInTab:)
                 keyEquivalent:@""];
        [menu addItemWithTitle:@"Open in New Window"
                        action:@selector(openProfileInWindow:)
                 keyEquivalent:@""];
    } else if (count > 1) {
        [menu addItemWithTitle:@"Open in New Tabs"
                        action:@selector(openProfileInTab:)
                 keyEquivalent:@""];
        [menu addItemWithTitle:@"Open in New Windows"
                        action:@selector(openProfileInWindow:)
                 keyEquivalent:@""];
    }
    return menu;
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nonTerminalWindowBecameKey"
                                                        object:nil
                                                      userInfo:nil];
    [tableView_ focusSearchField];
}

- (IBAction)closeAfterOpeningChanged:(id)sender
{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:[closeAfterOpeningProfile_ state] == NSOnState]
              forKey:@"CloseBookmarksWindowAfterOpening"];
}


@end
