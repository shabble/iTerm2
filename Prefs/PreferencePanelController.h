/* -*- mode:objc -*-
 **
 **  PreferencePanelController.h
 **
 **  Copyright (c) 2011
 **
 **  Author: Tom Feist
 **
 **  Project: iTerm2
 **
 **  Description: Implements the main controller for the Preferences Window.
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
#import "Prefs/PreferencesModel.h"
#import "Profiles/BookmarkModel.h"
#import "Prefs/PreferencesProfilesHelper.h"
#import "Profiles/BookmarkListView.h"

@class iTermController;

@interface PreferencePanelController : NSWindowController 
{

  // helper class instances.
    PreferencesProfilesHelper *prefsProfilesHelper;
    PreferencesModel *prefsModel;


    BookmarkModel* dataSource;
    BOOL oneBookmarkMode;
    
    // This is actually the tab style. It takes one of these values:
    // 0: Metal
    // 1: Aqua
    // 2: Unified
    // other: Adium
    // Bound to Metal/Aqua/Unified/Adium button
    IBOutlet NSPopUpButton *windowStyle;
    int defaultWindowStyle;
    BOOL oneBookmarkOnly;
    
    // This gives a value from NSTabViewType, which as of OS 10.6 is:
    // Bound to Top/Bottom button
    // NSTopTabsBezelBorder     = 0,
    // NSLeftTabsBezelBorder    = 1,
    // NSBottomTabsBezelBorder  = 2,
    // NSRightTabsBezelBorder   = 3,
    // NSNoTabsBezelBorder      = 4,
    // NSNoTabsLineBorder       = 5,
    // NSNoTabsNoBorder         = 6
    IBOutlet NSPopUpButton *tabPosition;
    int defaultTabViewType;
    
    IBOutlet NSTextField* tagFilter;
    
    // Copy to clipboard on selection
    IBOutlet NSButton *selectionCopiesText;
    BOOL defaultCopySelection;
    
    // Middle button paste from clipboard
    IBOutlet NSButton *middleButtonPastesFromClipboard;
    BOOL defaultPasteFromClipboard;
    
    // Hide tab bar when there is only one session
    IBOutlet id hideTab;
    BOOL defaultHideTab;
    
    // Warn me when a session closes
    IBOutlet id promptOnClose;
    BOOL defaultPromptOnClose;
    
    // Warn when quitting
    IBOutlet id promptOnQuit;
    BOOL defaultPromptOnQuit;
    
    // only when multiple sessions close
    IBOutlet id onlyWhenMoreTabs;
    BOOL defaultOnlyWhenMoreTabs;
    
    // Focus follows mouse
    IBOutlet NSButton *focusFollowsMouse;
    BOOL defaultFocusFollowsMouse;
    
    // Characters considered part of word
    IBOutlet NSTextField *wordChars;
    NSString *defaultWordChars;
    
    // Hotkey opens dedicated window
    IBOutlet NSButton* hotkeyTogglesWindow;
    BOOL defaultHotkeyTogglesWindow;
    IBOutlet NSPopUpButton* hotkeyBookmark;
    NSString* defaultHotKeyBookmarkGuid;
    
    // Enable bonjour
    IBOutlet NSButton *enableBonjour;
    BOOL defaultEnableBonjour;
    
    // cmd-click to launch url
    IBOutlet NSButton *cmdSelection;
    BOOL defaultCmdSelection;
    
    // pass on ctrl-click
    IBOutlet NSButton* passOnControlLeftClick;
    BOOL defaultPassOnControlLeftClick;
    
    // Zoom vertically only
    IBOutlet NSButton *maxVertically;
    BOOL defaultMaxVertically;
    
    // Closing hotkey window may switch Spaces
    IBOutlet NSButton* closingHotkeySwitchesSpaces;
    BOOL defaultClosingHotkeySwitchesSpaces;
    
    // use compact tab labels
    IBOutlet NSButton *useCompactLabel;
    BOOL defaultUseCompactLabel;
    
    // Highlight tab labels on activity
    IBOutlet NSButton *highlightTabLabels;
    BOOL defaultHighlightTabLabels;
    
    // Advanced font rendering
    IBOutlet NSButton* advancedFontRendering;
    BOOL defaultAdvancedFontRendering;
    IBOutlet NSSlider* strokeThickness;
    float defaultStrokeThickness;
    IBOutlet NSTextField* strokeThicknessLabel;
    IBOutlet NSTextField* strokeThicknessMinLabel;
    IBOutlet NSTextField* strokeThicknessMaxLabel;
    
    // Minimum contrast
    IBOutlet NSSlider* minimumContrast;
    
    // open bookmarks when iterm starts
    IBOutlet NSButton *openBookmark;
    BOOL defaultOpenBookmark;
    
    // quit when all windows are closed
    IBOutlet NSButton *quitWhenAllWindowsClosed;
    BOOL defaultQuitWhenAllWindowsClosed;
    
    // check for updates automatically
    IBOutlet NSButton *checkUpdate;
    BOOL defaultCheckUpdate;
    
    // cursor type: underline/vertical bar/box
    // See ITermCursorType. One of: CURSOR_UNDERLINE, CURSOR_VERTICAL, CURSOR_BOX
    IBOutlet NSMatrix *cursorType;
    
    IBOutlet NSButton *checkColorInvertedCursor;
    BOOL defaultColorInvertedCursor;
    
    // Dim inactive split panes
    IBOutlet NSButton* dimInactiveSplitPanes;
    BOOL defaultDimInactiveSplitPanes;
    
    // Window border
    IBOutlet NSButton* showWindowBorder;
    BOOL defaultShowWindowBorder;
    
    // hide scrollbar and resize
    IBOutlet NSButton *hideScrollbar;
    BOOL defaultHideScrollbar;
    
    // smart window placement
    IBOutlet NSButton *smartPlacement;
    BOOL defaultSmartPlacement;
    
    // Delay before showing tabs in fullscreen mode
    IBOutlet NSSlider* fsTabDelay;
    float defaultFsTabDelay;
    
    // Window/tab title customization
    IBOutlet NSButton* windowNumber;
    BOOL defaultWindowNumber;
    
    // Show job name in title
    IBOutlet NSButton* jobName;
    BOOL defaultJobName;
    
    // Show bookmark name in title
    IBOutlet NSButton* showBookmarkName;
    BOOL defaultShowBookmarkName;
    
    // instant replay
    IBOutlet NSButton *instantReplay;
    BOOL defaultInstantReplay;
    
    // instant replay memory usage.
    IBOutlet NSTextField* irMemory;
    int defaultIrMemory;
    
    // hotkey
    IBOutlet NSButton *hotkey;
    IBOutlet NSTextField* hotkeyLabel;
    BOOL defaultHotkey;
    
    // hotkey code
    IBOutlet NSTextField* hotkeyField;
    int defaultHotkeyChar;
    int defaultHotkeyCode;
    int defaultHotkeyModifiers;
    
    // Save copy paste history
    IBOutlet NSButton *savePasteHistory;
    BOOL defaultSavePasteHistory;
    
    // Open saved window arrangement at startup
    IBOutlet NSButton *openArrangementAtStartup;
    BOOL defaultOpenArrangementAtStartup;
    
    // prompt for test-release updates
    IBOutlet NSButton *checkTestRelease;
    BOOL defaultCheckTestRelease;
    
    IBOutlet NSTabViewItem* bookmarkSettingsGeneralTab;
    
    NSUserDefaults *prefs;
    
    IBOutlet NSToolbar* toolbar;
    IBOutlet NSTabView* tabView;
    IBOutlet NSToolbarItem* globalToolbarItem;
    IBOutlet NSTabViewItem* globalTabViewItem;
    IBOutlet NSToolbarItem* appearanceToolbarItem;
    IBOutlet NSTabViewItem* appearanceTabViewItem;
    IBOutlet NSToolbarItem* keyboardToolbarItem;
    IBOutlet NSTabViewItem* keyboardTabViewItem;
    IBOutlet NSToolbarItem* bookmarksToolbarItem;
    IBOutlet NSTabViewItem* bookmarksTabViewItem;
    NSString* globalToolbarId;
    NSString* appearanceToolbarId;
    NSString* keyboardToolbarId;
    NSString* bookmarksToolbarId;
    
    // url handler stuff
    NSMutableDictionary *urlHandlersByGuid;
    
   }

typedef enum { BulkCopyColors, BulkCopyDisplay, BulkCopyWindow, BulkCopyTerminal, BulkCopyKeyboard } BulkCopySettings;

+ (PreferencePanelController *)sharedInstance;
+ (PreferencePanelController *)sessionsInstance;

+ (BOOL)migratePreferences;

@property (readwrite,retain) PreferencesProfilesHelper *prefsProfilesHelper;
@property (readwrite,retain) PreferencesModel *prefsModel;

- (id)initWithDataSource:(BookmarkModel*)model userDefaults:(NSUserDefaults*)userDefaults;

- (IBAction)showGlobalTabView:(id)sender;
- (IBAction)showAppearanceTabView:(id)sender;
- (IBAction)showBookmarksTabView:(id)sender;
- (IBAction)showKeyboardTabView:(id)sender;


- (void)setOneBookmarkOnly;

- (void)awakeFromNib;
- (void)handleWindowWillCloseNotification:(NSNotification *)notification;
- (void)genericCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (void)editKeyMapping:(id)sender;
- (IBAction)saveKeyMapping:(id)sender;
- (BOOL)keySheetIsOpen;

- (IBAction)closeKeyMapping:(id)sender;

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar;

- (void)dealloc;

- (void)readPreferences;
- (void)savePreferences;

- (void)run;

- (IBAction)settingChanged:(id)sender;
- (BOOL)advancedFontRendering;
- (float)strokeThickness;
- (float)fsTabDelay;
- (int)modifierTagToMask:(int)tag;
- (void)windowWillLoad;
- (void)windowWillClose:(NSNotification *)aNotification;
- (void)windowDidBecomeKey:(NSNotification *)aNotification;
- (BOOL)copySelection;
- (void)setCopySelection:(BOOL)flag;
- (BOOL)pasteFromClipboard;
- (void)setPasteFromClipboard:(BOOL)flag;
- (BOOL)hideTab;
- (void)setTabViewType:(NSTabViewType)type;
- (NSTabViewType)tabViewType;
- (int)windowStyle;
- (BOOL)promptOnClose;
- (BOOL)promptOnQuit;
- (BOOL)onlyWhenMoreTabs;
- (BOOL)focusFollowsMouse;
- (BOOL)enableBonjour;

// Returns true if ANY profile has growl enabled (preserves interface from back
// when there was a global growl setting as well as a per-profile setting).
- (BOOL)enableGrowl;

- (BOOL)cmdSelection;
- (BOOL)passOnControlLeftClick;
- (BOOL)maxVertically;
- (BOOL)closingHotkeySwitchesSpaces;
- (BOOL)useCompactLabel;
- (BOOL)highlightTabLabels;
- (BOOL)openBookmark;
- (NSString *)wordChars;
- (ITermCursorType)legacyCursorType;
- (BOOL)hideScrollbar;
- (BOOL)smartPlacement;
- (BOOL)windowNumber;
- (BOOL)jobName;
- (BOOL)showBookmarkName;
- (BOOL)instantReplay;
- (BOOL)savePasteHistory;
- (BOOL)openArrangementAtStartup;
- (int)irMemory;
- (BOOL)hotkey;
- (int)hotkeyCode;
- (int)hotkeyModifiers;
- (NSTextField*)hotkeyField;

- (BOOL)showWindowBorder;
- (BOOL)dimInactiveSplitPanes;
- (BOOL)checkTestRelease;
- (BOOL)legacySmartCursorColor;
- (float)legacyMinimumContrast;
- (BOOL)quitWhenAllWindowsClosed;
- (BOOL)useUnevenTabs;
- (int)minTabWidth;
- (int)minCompactTabWidth;
- (int)optimumTabWidth;
- (float)hotkeyTermAnimationDuration;
- (NSString *)searchCommand;
- (Bookmark *)handlerBookmarkForURL:(NSString *)url;
- (int)numberOfRowsInTableView: (NSTableView *)aTableView;
- (NSString*)keyComboAtIndex:(int)rowIndex originator:(id)originator;
- (NSDictionary*)keyInfoAtIndex:(int)rowIndex originator:(id)originator;
- (NSString*)formattedKeyCombinationForRow:(int)rowIndex originator:(id)originator;
- (NSString*)formattedActionForRow:(int)rowIndex originator:(id)originator;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)_updateFontsDisplay;
- (void)updateBookmarkFields:(NSDictionary *)dict  ;
- (void)_commonDisplaySelectFont:(id)sender;
- (IBAction)displaySelectFont:(id)sender;
- (void)changeFont:(id)fontManager;
- (NSString*)_chooseBackgroundImage;
- (IBAction)bookmarkSettingChanged:(id)sender;
- (IBAction)copyToProfile:(id)sender;
- (IBAction)bookmarkUrlSchemeHandlerChanged:(id)sender;
- (void)connectBookmarkWithGuid:(NSString*)guid toScheme:(NSString*)scheme;
- (void)disconnectHandlerForScheme:(NSString*)scheme;
- (IBAction)closeWindow:(id)sender;
- (void)controlTextDidChange:(NSNotification *)aNotification;
- (void)textDidChange:(NSNotification *)aNotification;
- (BOOL)onScreen;
- (NSTextField*)shortcutKeyTextField;
- (void)shortcutKeyDown:(NSEvent*)event;
- (void)hotkeyKeyDown:(NSEvent*)event;
- (void)disableHotkey;
- (void)updateValueToSend;
- (IBAction)actionChanged:(id)sender;
- (NSWindow*)keySheet;
- (IBAction)addNewMapping:(id)sender;
- (IBAction)removeMapping:(id)sender;
- (IBAction)globalRemoveMapping:(id)sender;
- (void)setKeyMappingsToPreset:(NSString*)presetName;
- (IBAction)presetKeyMappingsItemSelected:(id)sender;

- (int)control;
- (int)leftOption;
- (int)rightOption;
- (int)leftCommand;
- (int)rightCommand;
- (BOOL)isAnyModifierRemapped;
- (int)switchTabModifier;
- (int)switchWindowModifier;

- (BOOL)hotkeyTogglesWindow;
- (BOOL)dockIconTogglesWindow;
- (Bookmark*)hotkeyBookmark;
- (void)copyAttributes:(BulkCopySettings)attributes fromBookmark:(NSString*)guid toBookmark:(NSString*)destGuid;

@end

