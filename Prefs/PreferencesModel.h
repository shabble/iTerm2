/* -*- mode:objc -*-
 **
 **  PreferencesModel.h
 **
 **  Copyright (c) 2011
 **
 **  Author: Tom Feist
 **
 **  Project: iTerm2
 **
 **  Description: Implements the model for holding preference (config) data.
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

#define OPT_NORMAL 0
#define OPT_META   1
#define OPT_ESC    2

// Modifier tags
#define MOD_TAG_CONTROL       1
#define MOD_TAG_LEFT_OPTION   2
#define MOD_TAG_RIGHT_OPTION  3
#define MOD_TAG_ANY_COMMAND   4
#define MOD_TAG_OPTION        5  // refers to any option key
#define MOD_TAG_CMD_OPT       6  // both cmd and opt at the same time
#define MOD_TAG_LEFT_COMMAND  7
#define MOD_TAG_RIGHT_COMMAND 8

typedef enum { CURSOR_UNDERLINE, CURSOR_VERTICAL, CURSOR_BOX } ITermCursorType;



#import <Cocoa/Cocoa.h>
#import "Profiles/ProfileModel.h"
#import "Profiles/ProfilesListView.h"

//
//  UserModel.h
//  colour-matrix
//
//  Created by shabble on 16/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSUserDefaults+NSColorSupport.h"

@interface UserModel : NSObject {
    
    NSUserDefaultsController *userDefaultsController_;
    NSSet *validKeys_;
    BOOL  resetInProgress_;
}

@property (nonatomic,readwrite,assign) NSUserDefaultsController *userDefaultsController;

- (void)resetToFactoryDefaults;
- (void)saveToUserPreferences;
- (void)loadFromUserPreferences;

- (void)updateAllModelValues;
- (void)configureUserDefaults;

- (id)prefs;
- (NSDictionary*)initialValues;

@end

@interface UserModel (KeyValueCoding)

- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey;

@end


@interface PreferencesModel : NSObject {

    ProfileModel* profileDataSource;
    BOOL           oneProfileMode;

    // This is actually the tab style. It takes one of these values:
    // 0: Metal
    // 1: Aqua
    // 2: Unified
    // other: Adium
    // Bound to Metal/Aqua/Unified/Adium button
    int defaultWindowStyle;
    BOOL oneProfileOnly; // redundant? See oneProfileMode above.

    // This gives a value from NSTabViewType, which as of OS 10.6 is:
    // Bound to Top/Bottom button
    // NSTopTabsBezelBorder     = 0,
    // NSLeftTabsBezelBorder    = 1,
    // NSBottomTabsBezelBorder  = 2,
    // NSRightTabsBezelBorder   = 3,
    // NSNoTabsBezelBorder      = 4,
    // NSNoTabsLineBorder       = 5,
    // NSNoTabsNoBorder         = 6
    int defaultTabViewType;

    // Copy to clipboard on selection
    BOOL defaultCopySelection;

    // Middle button paste from clipboard
    BOOL defaultPasteFromClipboard;

    // Hide tab bar when there is only one session
    BOOL defaultHideTab;

    // Warn me when a session closes
    BOOL defaultPromptOnClose;

    // Warn when quitting
    BOOL defaultPromptOnQuit;

    // only when multiple sessions close
    BOOL defaultOnlyWhenMoreTabs;

    // Focus follows mouse
    BOOL defaultFocusFollowsMouse;

    // Characters considered part of word
    NSString *defaultWordChars;

    // Hotkey opens dedicated window
    BOOL defaultHotkeyTogglesWindow;

    // TODO: ???
    NSString* defaultHotKeyProfileGuid;

    // Enable bonjour
    BOOL defaultEnableBonjour;

    // cmd-click to launch url
    BOOL defaultCmdSelection;

    // pass on ctrl-click
    BOOL defaultPassOnControlLeftClick;

    // Zoom vertically only
    BOOL defaultMaxVertically;

    // Closing hotkey window may switch Spaces
    BOOL defaultClosingHotkeySwitchesSpaces;

    // use compact tab labels
    BOOL defaultUseCompactLabel;

    // Highlight tab labels on activity
    BOOL defaultHighlightTabLabels;

    // Advanced font rendering
    BOOL defaultAdvancedFontRendering;
    float defaultStrokeThickness;

    // Minimum contrast

    // open profiles when iterm starts
    BOOL defaultOpenProfile;

    // quit when all windows are closed
    BOOL defaultQuitWhenAllWindowsClosed;

    // check for updates automatically
    BOOL defaultCheckUpdate;

    // cursor type: underline/vertical bar/box
    // See ITermCursorType. One of: CURSOR_UNDERLINE, CURSOR_VERTICAL, CURSOR_BOX

    BOOL defaultColorInvertedCursor;

    // Dim inactive split panes
    BOOL defaultDimInactiveSplitPanes;

    // Window border
    BOOL defaultShowWindowBorder;

    // hide scrollbar and resize
    BOOL defaultHideScrollbar;

    // smart window placement
    BOOL defaultSmartPlacement;

    // Delay before showing tabs in fullscreen mode
    float defaultFsTabDelay;

    // Window/tab title customization
    BOOL defaultWindowNumber;

    // Show job name in title
    BOOL defaultJobName;

    // Show profile name in title
    BOOL defaultShowProfileName;

    // instant replay
    BOOL defaultInstantReplay;

    // instant replay memory usage.
    int defaultIrMemory;

    // hotkey
    BOOL defaultHotkey;

    // hotkey code
    int defaultHotkeyChar;
    int defaultHotkeyCode;
    int defaultHotkeyModifiers;

    // Save copy paste history
    BOOL defaultSavePasteHistory;

    // Open saved window arrangement at startup
    BOOL defaultOpenArrangementAtStartup;

    // prompt for test-release updates
    BOOL defaultCheckTestRelease;


    NSUserDefaults *prefs;

    NSString* globalToolbarId;
    NSString* appearanceToolbarId;
    NSString* keyboardToolbarId;
    NSString* profilesToolbarId;

    // url handler stuff
    NSMutableDictionary *urlHandlersByGuid;

    // Profiles -----------------------------

    // General tab

    // Colors tab

    // Display tab


    NSString* backgroundImageFilename;

    NSFont* normalFont;
    NSFont *nonAsciiFont;
    BOOL changingNAFont; // true if font dialog is currently modifying the non-ascii font

    // Terminal tab

    // Keyboard tab


    NSString* keyString;  // hexcode-hexcode rep of keystring in current sheet
    BOOL newMapping;  // true if the keymap sheet is open for adding a new entry
    id modifyMappingOriginator;  // widget that caused add new mapping window to open

    // Copy Profile Settings...

    // Keyboard ------------------------------
    int defaultControl;
    int defaultLeftOption;
    int defaultRightOption;
    int defaultLeftCommand;
    int defaultRightCommand;

    int defaultSwitchTabModifier;
    int defaultSwitchWindowModifier;

    
    
    // NEW APPROACH
    NSMutableDictionary *preferences;
}

@property (readwrite,retain) NSMutableDictionary *preferences;


@property (readwrite,retain) ProfileModel *profileDataSource;
@property (readwrite,assign) BOOL           oneProfileMode;

    // This is actually the tab style. It takes one of these values:
    // 0: Metal
    // 1: Aqua
    // 2: Unified
    // other: Adium
    // Bound to Metal/Aqua/Unified/Adium button
@property (readwrite,assign) int  defaultWindowStyle;
@property (readwrite,assign) BOOL oneProfileOnly; 

    // This gives a value from NSTabViewType, which as of OS 10.6 is:
    // Bound to Top/Bottom button
    // NSTopTabsBezelBorder     = 0,
    // NSLeftTabsBezelBorder    = 1,
    // NSBottomTabsBezelBorder  = 2,
    // NSRightTabsBezelBorder   = 3,
    // NSNoTabsBezelBorder      = 4,
    // NSNoTabsLineBorder       = 5,
    // NSNoTabsNoBorder         = 6
@property (readwrite,assign) int defaultTabViewType;

    // Copy to clipboard on selection
@property (readwrite,assign) BOOL defaultCopySelection;

    // Middle button paste from clipboard
@property (readwrite,assign) BOOL defaultPasteFromClipboard;

    // Hide tab bar when there is only one session
@property (readwrite,assign) BOOL defaultHideTab;

    // Warn me when a session closes
@property (readwrite,assign) BOOL defaultPromptOnClose;

    // Warn when quitting
@property (readwrite,assign) BOOL defaultPromptOnQuit;

    // only when multiple sessions close
@property (readwrite,assign) BOOL defaultOnlyWhenMoreTabs;

    // Focus follows mouse
@property (readwrite,assign) BOOL defaultFocusFollowsMouse;

    // Characters considered part of word
@property (readwrite,copy)   NSString *defaultWordChars;

    // Hotkey opens dedicated window
@property (readwrite,assign) BOOL defaultHotkeyTogglesWindow;

    // TODO: ???
@property (readwrite,copy)   NSString* defaultHotKeyProfileGuid;

    // Enable bonjour
@property (readwrite,assign) BOOL defaultEnableBonjour;

    // cmd-click to launch url
@property (readwrite,assign) BOOL defaultCmdSelection;

    // pass on ctrl-click
@property (readwrite,assign) BOOL defaultPassOnControlLeftClick;

    // Zoom vertically only
@property (readwrite,assign) BOOL defaultMaxVertically;

    // Closing hotkey window may switch Spaces
@property (readwrite,assign) BOOL defaultClosingHotkeySwitchesSpaces;

    // use compact tab labels
@property (readwrite,assign) BOOL defaultUseCompactLabel;

    // Highlight tab labels on activity
@property (readwrite,assign) BOOL defaultHighlightTabLabels;

    // Advanced font rendering
@property (readwrite,assign) BOOL defaultAdvancedFontRendering;
@property (readwrite,assign) float defaultStrokeThickness;

    // Minimum contrast

    // open profiles when iterm starts
@property (readwrite,assign) BOOL defaultOpenProfile;

    // quit when all windows are closed
@property (readwrite,assign) BOOL defaultQuitWhenAllWindowsClosed;

    // check for updates automatically
@property (readwrite,assign) BOOL defaultCheckUpdate;

    // cursor type: underline/vertical bar/box
    // See ITermCursorType. One of: CURSOR_UNDERLINE, CURSOR_VERTICAL, CURSOR_BOX

@property (readwrite,assign) BOOL defaultColorInvertedCursor;

    // Dim inactive split panes
@property (readwrite,assign) BOOL defaultDimInactiveSplitPanes;

    // Window border
@property (readwrite,assign) BOOL defaultShowWindowBorder;

    // hide scrollbar and resize
@property (readwrite,assign) BOOL defaultHideScrollbar;

    // smart window placement
@property (readwrite,assign) BOOL defaultSmartPlacement;

    // Delay before showing tabs in fullscreen mode
@property (readwrite,assign) float defaultFsTabDelay;

    // Window/tab title customization
@property (readwrite,assign) BOOL defaultWindowNumber;

    // Show job name in title
@property (readwrite,assign) BOOL defaultJobName;

    // Show profile name in title
@property (readwrite,assign) BOOL defaultShowProfileName;

    // instant replay
@property (readwrite,assign) BOOL defaultInstantReplay;

    // instant replay memory usage.
@property (readwrite,assign) int defaultIrMemory;

    // hotkey enabled
@property (readwrite,assign) BOOL defaultHotkey;

    // hotkey code
@property (readwrite,assign) int defaultHotkeyChar;
@property (readwrite,assign) int defaultHotkeyCode;
@property (readwrite,assign) int defaultHotkeyModifiers;

    // Save copy paste history
@property (readwrite,assign) BOOL defaultSavePasteHistory;

    // Open saved window arrangement at startup
@property (readwrite,assign) BOOL defaultOpenArrangementAtStartup;

    // prompt for test-release updates
@property (readwrite,assign) BOOL defaultCheckTestRelease;

@property (readwrite,retain) NSUserDefaults *prefs;

@property (readwrite,copy)   NSString* globalToolbarId;
@property (readwrite,copy)   NSString* appearanceToolbarId;
@property (readwrite,copy)   NSString* keyboardToolbarId;
@property (readwrite,copy)   NSString* profilesToolbarId;

    // url handler stuff
@property (readwrite,retain) NSMutableDictionary *urlHandlersByGuid;

@property (readwrite,copy)   NSString* backgroundImageFilename;

@property (readwrite,retain) NSFont* normalFont;
@property (readwrite,retain) NSFont *nonAsciiFont;

// true if font dialog is currently modifying the non-ascii font
@property (readwrite,assign) BOOL changingNAFont; 

// hexcode-hexcode rep of keystring in current sheet
@property (readwrite,copy)   NSString* keyString;  

// true if the keymap sheet is open for adding a new entry
@property (readwrite,assign) BOOL newMapping;  

// widget that caused add new mapping window to open
@property (readwrite,retain) id modifyMappingOriginator;  

@property (readwrite,assign) int defaultControl;
@property (readwrite,assign) int defaultLeftOption;
@property (readwrite,assign) int defaultRightOption;
@property (readwrite,assign) int defaultLeftCommand;
@property (readwrite,assign) int defaultRightCommand;

@property (readwrite,assign) int defaultSwitchTabModifier;
@property (readwrite,assign) int defaultSwitchWindowModifier;

// TODO: 
// * add +migrateProfiles
// * add load/save code
// * add obj instance to xib?
@end
