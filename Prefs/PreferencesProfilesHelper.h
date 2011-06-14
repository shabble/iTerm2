/* -*- mode:objc -*-
 **
 **  PreferencesProfilesHelper.h
 **
 **  Copyright (c) 2011
 **
 **  Author: Tom Feist
 **
 **  Project: iTerm2
 **
 **  Description: 
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
#import "Profiles/ProfilesModel.h"
#import "Profiles/ProfilesListView.h"
#import "Prefs/PreferencesModel.h"
#import "Prefs/PreferenceKeys.h"


@interface PreferencesProfilesHelper : NSObject <ProfilesTableDelegate> 
{
    
    IBOutlet NSTabView* profilesSettingsTabViewParent;
    
    // Profiles -----------------------------
    IBOutlet ProfilesListView *profilesTableView;
    IBOutlet NSTableColumn    *shellImageColumn;
    IBOutlet NSTableColumn    *nameShortcutColumn;
    IBOutlet NSButton         *removeProfileButton;
    IBOutlet NSButton         *addProfileButton;
    
    // General tab
    IBOutlet NSTextField   *profileName;
    IBOutlet NSPopUpButton *profileShortcutKey;
    IBOutlet NSMatrix      *profileCommandType;
    IBOutlet NSTextField   *profileCommand;
    IBOutlet NSMatrix      *profileDirectoryType;
    IBOutlet NSTextField   *profileDirectory;
    IBOutlet NSTextField   *profileShortcutKeyLabel;
    IBOutlet NSTextField   *profileShortcutKeyModifiersLabel;
    IBOutlet NSTextField   *profileTagsLabel;
    IBOutlet NSTextField   *profileCommandLabel;
    IBOutlet NSTextField   *profileDirectoryLabel;
    IBOutlet NSTextField   *profileUrlSchemesHeaderLabel;
    IBOutlet NSTextField   *profileUrlSchemesLabel;
    IBOutlet NSPopUpButton *profileUrlSchemes;
    IBOutlet NSButton      *copyToProfileButton;
    
    // Colors tab
    IBOutlet NSColorWell *ansi0Color;
    IBOutlet NSColorWell *ansi1Color;
    IBOutlet NSColorWell *ansi2Color;
    IBOutlet NSColorWell *ansi3Color;
    IBOutlet NSColorWell *ansi4Color;
    IBOutlet NSColorWell *ansi5Color;
    IBOutlet NSColorWell *ansi6Color;
    IBOutlet NSColorWell *ansi7Color;
    IBOutlet NSColorWell *ansi8Color;
    IBOutlet NSColorWell *ansi9Color;
    IBOutlet NSColorWell *ansi10Color;
    IBOutlet NSColorWell *ansi11Color;
    IBOutlet NSColorWell *ansi12Color;
    IBOutlet NSColorWell *ansi13Color;
    IBOutlet NSColorWell *ansi14Color;
    IBOutlet NSColorWell *ansi15Color;
    IBOutlet NSColorWell *foregroundColor;
    IBOutlet NSColorWell *backgroundColor;
    IBOutlet NSColorWell *boldColor;
    IBOutlet NSColorWell *selectionColor;
    IBOutlet NSColorWell *selectedTextColor;
    IBOutlet NSColorWell *cursorColor;
    IBOutlet NSColorWell *cursorTextColor;
    IBOutlet NSTextField *cursorColorLabel;
    IBOutlet NSTextField *cursorTextColorLabel;
    IBOutlet NSMenu *presetsMenu;
    
    // Display tab
    IBOutlet NSView *displayFontAccessoryView;
    IBOutlet NSSlider *displayFontSpacingWidth;
    IBOutlet NSSlider *displayFontSpacingHeight;
    IBOutlet NSTextField *columnsField;
    IBOutlet NSTextField *columnsLabel;
    IBOutlet NSTextField *rowsLabel;
    IBOutlet NSTextField *rowsField;
    IBOutlet NSTextField* windowTypeLabel;
    IBOutlet NSPopUpButton* screenButton;
    IBOutlet NSTextField* spaceLabel;
    IBOutlet NSPopUpButton* spaceButton;
    
    IBOutlet NSPopUpButton* windowTypeButton;
    IBOutlet NSTextField *normalFontField;
    IBOutlet NSTextField *nonAsciiFontField;
    IBOutlet NSTextField *newWindowttributesHeader;
    IBOutlet NSTextField *screenLabel;
    
    IBOutlet NSButton* blinkingCursor;
    IBOutlet NSButton* blinkAllowed;
    IBOutlet NSButton* useBoldFont;
    IBOutlet NSButton* useBrightBold;
    IBOutlet NSSlider *transparency;
    IBOutlet NSButton* blur;
    IBOutlet NSButton* asciiAntiAliased;
    IBOutlet NSButton* nonasciiAntiAliased;
    IBOutlet NSButton* backgroundImage;
    NSString* backgroundImageFilename;
    IBOutlet NSImageView* backgroundImagePreview;
    IBOutlet NSTextField* displayFontsLabel;
    IBOutlet NSButton* displayRegularFontButton;
    IBOutlet NSButton* displayNAFontButton;
    
    NSFont* normalFont;
    NSFont *nonAsciiFont;
    BOOL changingNAFont; // true if font dialog is currently modifying the non-ascii font
    
    // Terminal tab
    IBOutlet NSButton* disableWindowResizing;
    IBOutlet NSButton* syncTitle;
    IBOutlet NSButton* closeSessionsOnEnd;
    IBOutlet NSButton* nonAsciiDoubleWidth;
    IBOutlet NSButton* silenceBell;
    IBOutlet NSButton* visualBell;
    IBOutlet NSButton* flashingBell;
    IBOutlet NSButton* xtermMouseReporting;
    IBOutlet NSButton* disableSmcupRmcup;
    IBOutlet NSButton* scrollbackWithStatusBar;
    IBOutlet NSButton* bookmarkGrowlNotifications;
    IBOutlet NSTextField* scrollbackLines;
    IBOutlet NSButton* unlimitedScrollback;
    IBOutlet NSComboBox* terminalType;
    IBOutlet NSButton* sendCodeWhenIdle;
    IBOutlet NSTextField* idleCode;
    IBOutlet NSPopUpButton* characterEncoding;
    
    // Keyboard tab
    IBOutlet NSTableView* keyMappings;
    IBOutlet NSTableColumn* keyCombinationColumn;
    IBOutlet NSTableColumn* actionColumn;
    IBOutlet NSWindow* editKeyMappingWindow;
    IBOutlet NSTextField* keyPress;
    IBOutlet NSPopUpButton* action;
    IBOutlet NSTextField* valueToSend;
    IBOutlet NSTextField* profileLabel;
    IBOutlet NSPopUpButton* bookmarkPopupButton;
    IBOutlet NSPopUpButton* menuToSelect;
    IBOutlet NSButton* removeMappingButton;
    IBOutlet NSTextField* escPlus;
    IBOutlet NSMatrix *optionKeySends;
    IBOutlet NSMatrix *rightOptionKeySends;
    IBOutlet NSTokenField* tags;
    
    IBOutlet NSPopUpButton* presetsPopupButton;
    IBOutlet NSTextField*   presetsErrorLabel;
    
    NSString* keyString;  // hexcode-hexcode rep of keystring in current sheet
    BOOL newMapping;  // true if the keymap sheet is open for adding a new entry
    id modifyMappingOriginator;  // widget that caused add new mapping window to open
    IBOutlet NSPopUpButton* bookmarksPopup;
    IBOutlet NSButton* addNewMapping;
    
    // Copy Bookmark Settings...
    /*
    IBOutlet NSTextField* bulkCopyLabel;
    IBOutlet NSPanel* copyPanel;
    IBOutlet NSButton* copyColors;
    IBOutlet NSButton* copyDisplay;
    IBOutlet NSButton* copyTerminal;
    IBOutlet NSButton* copyWindow;
    IBOutlet NSButton* copyKeyboard;
    IBOutlet BookmarkListView* copyTo;
    IBOutlet NSButton* copyButton;
    */
    
    
    
    ProfilesTableView *tableView;
    PreferencesModel *dataSource;
}

@property (readwrite,retain) ProfilesTableView *tableView;
@property (readwrite,retain) PreferencesModel  *dataSource;

+ (id)initWithBookmarkTableView:(ProfilesTableView*)view;

- (void)tableViewSelectionDidChange:(NSNotification*)aNotification;
- (NSMenu*)bookmarkTable:(id)bookmarkTable menuForEvent:(NSEvent*)theEvent;
- (void)bookmarkTableSelectionDidChange:(id)bookmarkTable;
- (void)bookmarkTableSelectionWillChange:(id)aBookmarkTableView;
- (void)bookmarkTableRowSelected:(id)bookmarkTable;

- (void)_loadPresetColors:(NSString*)presetName;
- (void)loadColorPreset:(id)sender;
- (IBAction)addProfile:(id)sender;
- (IBAction)removeProfile:(id)sender;
- (IBAction)duplicateProfile:(id)sender;
- (IBAction)setAsDefault:(id)sender;
- (NSArray *)tokenField:(NSTokenField*)tokenField completionsForSubstring:(NSString*)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex;
- (void)showProfiles;
- (void)openToProfile:(NSString*)guid;
- (id)tokenFieldCell:(NSTokenFieldCell*)tokenFieldCell representedObjectForEditingString:(NSString*)editingString;
- (void)underlyingProfileDidChange;

- (IBAction)openCopyProfiles:(id)sender;
- (IBAction)copyProfiles:(id)sender;
- (IBAction)cancelCopyProfiles:(id)sender;



- (BOOL)remappingDisabledTemporarily;

//- (IBAction)duplicateBookmark:(id)sender;

@end
