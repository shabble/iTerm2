/* -*- mode:objc -*-
 **
 **  PreferencesProfilesHelper.m
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

#import "Prefs/PreferencesProfilesHelper.h"
#import "Prefs/PreferencePanelController.h"
#import "Profiles/BookmarkModel.h"
#import "Prefs/PreferencesModel.h"


@implementation PreferencesProfilesHelper

@synthesize tableView;
@synthesize dataSource;

+ (id)initWithBookmarkTableView:(BookmarkTableView *)view
{
    if ((self = [super init])) {
        //[self setTableView:view];
    }
    return self;
}

// ================================================================
//                  BookmarkTableDelegate impl
// ================================================================

- (NSMenu*)bookmarkTable:(id)bookmarkTable menuForEvent:(NSEvent*)theEvent
{
    return nil;
}

- (void)bookmarkTableSelectionWillChange:(id)aBookmarkTableView
{
    if ([[bookmarksTableView selectedGuids] count] == 1) {
        PreferencePanelController *ctrl = [PreferencePanelController sharedInstance];
      [ctrl bookmarkSettingChanged:nil];
    }
}

- (void)bookmarkTableSelectionDidChange:(id)bookmarkTable
{
    PreferencePanelController *ppc = [PreferencePanelController sharedInstance];
    
    if ([[bookmarksTableView selectedGuids] count] != 1) {
        [bookmarksSettingsTabViewParent setHidden:YES];
        [bookmarksPopup setEnabled:NO];
        
        if ([[bookmarksTableView selectedGuids] count] == 0) {
            [removeBookmarkButton setEnabled:NO];
        } else {
            [removeBookmarkButton setEnabled:[[bookmarksTableView selectedGuids] count] < [[bookmarksTableView dataSource] numberOfBookmarks]];
        }
    } else {
        [bookmarksSettingsTabViewParent setHidden:NO];
        [bookmarksPopup setEnabled:YES];
        [removeBookmarkButton setEnabled:NO];
        if (bookmarkTable == bookmarksTableView) {
            NSString* guid = [bookmarksTableView selectedGuid];
            [self updateBookmarkFields:[dataSource bookmarkWithGuid:guid]];
        }
    }
}
/*
- (void)bookmarkTableSelectionDidChange:(id)bookmarkTable
{
    PreferencePanelController *ppc = [PreferencePanelController sharedInstance];
     if ([[tableView selectedGuids] count] != 1) {
         [[ppc bookmarksSettingsTabViewParent] setHidden:YES];
         [[ppc bookmarksPopup] setEnabled:NO];
     }        
         if ([[tableView selectedGuids] count] == 0) {
             [[ppc removeBookmarkButton] setEnabled:NO];
         } else {
             //[[ppc removeBookmarkButton] setEnabled:[[tableView selectedGuids] count] < [[tableView dataSource] numberOfBookmarks]];
         }
     } else {
         [[ppc bookmarksSettingsTabViewParent] setHidden:NO];
         [[ppc bookmarksPopup] setEnabled:YES];
         [[ppc removeBookmarkButton] setEnabled:NO];
         if (bookmarkTable == tableView) {
             NSString* guid = [tableView selectedGuid];
             [self updateBookmarkFields:[dataSource bookmarkWithGuid:guid]];
         }
     }
}
*/
- (void)bookmarkTableRowSelected:(id)bookmarkTable
{
    // Do nothing for double click
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
   /* //NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([aNotification object] == keyMappings) {
        int rowIndex = [keyMappings selectedRow];
        if (rowIndex >= 0) {
            [removeMappingButton setEnabled:YES];
        } else {
            [removeMappingButton setEnabled:NO];
        }
    } else if ([aNotification object] == globalKeyMappings) {
        int rowIndex = [globalKeyMappings selectedRow];
        if (rowIndex >= 0) {
            [globalRemoveMappingButton setEnabled:YES];
        } else {
            [globalRemoveMappingButton setEnabled:NO];
        }
    }*/
}
// ================================================================
//                           Others
// ================================================================

- (void)_loadPresetColors:(NSString*)presetName
{
    NSString* guid = [bookmarksTableView selectedGuid];
    NSAssert(guid, @"Null guid unexpected here");
    
    NSString* plistFile = [[NSBundle bundleForClass: [self class]] pathForResource:@"ColorPresets"
                                                                            ofType:@"plist"];
    NSDictionary* presetsDict = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    NSDictionary* settings = [presetsDict objectForKey:presetName];
    if (!settings) {
        presetsDict = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_COLOR_PRESETS];
        settings = [presetsDict objectForKey:presetName];
    }
    NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithDictionary:[dataSource bookmarkWithGuid:guid]];
    
    for (id colorName in settings) {
        NSDictionary* preset = [settings objectForKey:colorName];
        float r = [[preset objectForKey:@"Red Component"] floatValue];
        float g = [[preset objectForKey:@"Green Component"] floatValue];
        float b = [[preset objectForKey:@"Blue Component"] floatValue];
        NSColor* color = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1];
        NSAssert([newDict objectForKey:colorName], @"Missing color in existing dict");
        [newDict setObject:[ITAddressBookMgr encodeColor:color] forKey:colorName];
    }
    
    [dataSource setBookmark:newDict withGuid:guid];
    [self updateBookmarkFields:newDict];
    [self bookmarkSettingChanged:self];  // this causes existing sessions to be updated
}

- (void)loadColorPreset:(id)sender;
{
    [self _loadPresetColors:[sender title]];
}

- (IBAction)addBookmark:(id)sender
{
    NSMutableDictionary* newDict = [[NSMutableDictionary alloc] init];
    // Copy the default bookmark's settings in
    Bookmark* prototype = [dataSource defaultBookmark];
    if (!prototype) {
        [ITAddressBookMgr setDefaultsInBookmark:newDict];
    } else {
        [newDict setValuesForKeysWithDictionary:[dataSource defaultBookmark]];
    }
    [newDict setObject:@"New Profile" forKey:KEY_NAME];
    [newDict setObject:@"" forKey:KEY_SHORTCUT];
    NSString* guid = [BookmarkModel freshGuid];
    [newDict setObject:guid forKey:KEY_GUID];
    [newDict removeObjectForKey:KEY_DEFAULT_BOOKMARK];  // remove depreated attribute with side effects
    [newDict setObject:[NSArray arrayWithObjects:nil] forKey:KEY_TAGS];
    if ([[BookmarkModel sharedInstance] bookmark:newDict hasTag:@"bonjour"]) {
        [newDict removeObjectForKey:KEY_BONJOUR_GROUP];
        [newDict removeObjectForKey:KEY_BONJOUR_SERVICE];
        [newDict removeObjectForKey:KEY_BONJOUR_SERVICE_ADDRESS];
        [newDict setObject:@"" forKey:KEY_COMMAND];
        [newDict setObject:@"No" forKey:KEY_CUSTOM_COMMAND];
        [newDict setObject:@"" forKey:KEY_WORKING_DIRECTORY];
        [newDict setObject:@"No" forKey:KEY_CUSTOM_DIRECTORY];
    }
    [dataSource addBookmark:newDict];
    [bookmarksTableView reloadData];
    [bookmarksTableView eraseQuery];
    [bookmarksTableView selectRowByGuid:guid];
    [bookmarksSettingsTabViewParent selectTabViewItem:bookmarkSettingsGeneralTab];
    [[self window] makeFirstResponder:bookmarkName];
    [bookmarkName selectText:self];
}

- (void)_removeKeyMappingsReferringToBookmarkGuid:(NSString*)badRef
{
    for (NSString* guid in [[BookmarkModel sharedInstance] guids]) {
        Bookmark* bookmark = [[BookmarkModel sharedInstance] bookmarkWithGuid:guid];
        bookmark = [iTermKeyBindingMgr removeMappingsReferencingGuid:badRef fromBookmark:bookmark];
        if (bookmark) {
            [[BookmarkModel sharedInstance] setBookmark:bookmark withGuid:guid];
        }
    }
    for (NSString* guid in [[BookmarkModel sessionsInstance] guids]) {
        Bookmark* bookmark = [[BookmarkModel sessionsInstance] bookmarkWithGuid:guid];
        bookmark = [iTermKeyBindingMgr removeMappingsReferencingGuid:badRef fromBookmark:bookmark];
        if (bookmark) {
            [[BookmarkModel sessionsInstance] setBookmark:bookmark withGuid:guid];
        }
    }
    [iTermKeyBindingMgr removeMappingsReferencingGuid:badRef fromBookmark:nil];
    [[PreferencePanelController sharedInstance]->keyMappings reloadData];
    [[PreferencePanelController sessionsInstance]->keyMappings reloadData];
}

- (IBAction)removeBookmark:(id)sender
{
    if ([dataSource numberOfBookmarks] == 1) {
        NSBeep();
    } else {
        BOOL found = NO;
        int lastIndex = 0;
        int numRemoved = 0;
        for (NSString* guid in [bookmarksTableView selectedGuids]) {
            found = YES;
            int i = [bookmarksTableView selectedRow];
            if (i > lastIndex) {
                lastIndex = i;
            }
            ++numRemoved;
            [self _removeKeyMappingsReferringToBookmarkGuid:guid];
            [dataSource removeBookmarkWithGuid:guid];
        }
        [bookmarksTableView reloadData];
        int toSelect = lastIndex - numRemoved;
        if (toSelect < 0) {
            toSelect = 0;
        }
        [bookmarksTableView selectRowIndex:toSelect];
        if (!found) {
            NSBeep();
        }
    }
}

- (IBAction)setAsDefault:(id)sender
{
    NSString* guid = [bookmarksTableView selectedGuid];
    if (!guid) {
        NSBeep();
        return;
    }
    [dataSource setDefaultByGuid:guid];
}

- (IBAction)duplicateBookmark:(id)sender
{
    NSString* guid = [bookmarksTableView selectedGuid];
    if (!guid) {
        NSBeep();
        return;
    }
    Bookmark* bookmark = [dataSource bookmarkWithGuid:guid];
    NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithDictionary:bookmark];
    NSString* newName = [NSString stringWithFormat:@"Copy of %@", [newDict objectForKey:KEY_NAME]];
    
    [newDict setObject:newName forKey:KEY_NAME];
    [newDict setObject:[BookmarkModel freshGuid] forKey:KEY_GUID];
    [newDict setObject:@"No" forKey:KEY_DEFAULT_BOOKMARK];
    [dataSource addBookmark:newDict];
    [bookmarksTableView reloadData];
    [bookmarksTableView selectRowByGuid:[newDict objectForKey:KEY_GUID]];
}

- (BOOL)remappingDisabledTemporarily
{
    return [[self keySheet] isKeyWindow] && [self keySheetIsOpen] && ([action selectedTag] == KEY_ACTION_DO_NOT_REMAP_MODIFIERS ||
                                                                      [action selectedTag] == KEY_ACTION_REMAP_LOCALLY);
}

#pragma mark NSTokenField delegate

- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex
{
    if (tokenField != tags) {
        return nil;
    }
    
    NSArray *allTags = [[dataSource allTags] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *aTag in allTags) {
        if ([aTag hasPrefix:substring]) {
            [result addObject:[aTag retain]];
        }
    }
    return result;
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString
{
    return [editingString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark NSTokenFieldCell delegate

- (id)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell representedObjectForEditingString:(NSString *)editingString
{
    static BOOL running;
    if (!running) {
        running = YES;
        [self bookmarkSettingChanged:tags];
        running = NO;
    }
    return [editingString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark -

- (void)showBookmarks
{
    [tabView selectTabViewItem:bookmarksTabViewItem];
    [toolbar setSelectedItemIdentifier:bookmarksToolbarId];
}

- (void)openToBookmark:(NSString*)guid
{
    [self run];
    [self updateBookmarkFields:[dataSource bookmarkWithGuid:guid]];
    [self showBookmarks];
    [bookmarksTableView selectRowByGuid:guid];
    [bookmarksSettingsTabViewParent selectTabViewItem:bookmarkSettingsGeneralTab];
    [[self window] makeFirstResponder:bookmarkName];
}

- (IBAction)openCopyBookmarks:(id)sender
{
    [bulkCopyLabel setStringValue:[NSString stringWithFormat:
                                   @"Copy these settings from profile \"%@\":",
                                   [[dataSource bookmarkWithGuid:[bookmarksTableView selectedGuid]] objectForKey:KEY_NAME]]];
    [NSApp beginSheet:copyPanel
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(genericCloseSheet:returnCode:contextInfo:)
          contextInfo:nil];
}

- (IBAction)copyBookmarks:(id)sender
{
    NSString* srcGuid = [bookmarksTableView selectedGuid];
    if (!srcGuid) {
        NSBeep();
        return;
    }
    
    NSSet* destGuids = [copyTo selectedGuids];
    for (NSString* destGuid in destGuids) {
        if ([destGuid isEqualToString:srcGuid]) {
            continue;
        }
        
        if (![dataSource bookmarkWithGuid:destGuid]) {
            NSLog(@"Selected bookmark %@ doesn't exist", destGuid);
            continue;
        }
        
        if ([copyColors state] == NSOnState) {
            [self copyAttributes:BulkCopyColors fromBookmark:srcGuid toBookmark:destGuid];
        }
        if ([copyDisplay state] == NSOnState) {
            [self copyAttributes:BulkCopyDisplay fromBookmark:srcGuid toBookmark:destGuid];
        }
        if ([copyWindow state] == NSOnState) {
            [self copyAttributes:BulkCopyWindow fromBookmark:srcGuid toBookmark:destGuid];
        }
        if ([copyTerminal state] == NSOnState) {
            [self copyAttributes:BulkCopyTerminal fromBookmark:srcGuid toBookmark:destGuid];
        }
        if ([copyKeyboard state] == NSOnState) {
            [self copyAttributes:BulkCopyKeyboard fromBookmark:srcGuid toBookmark:destGuid];
        }
    }
    [NSApp endSheet:copyPanel];
}

- (IBAction)bookmarkSettingChanged:(id)sender
{
    NSString* name = [bookmarkName stringValue];
    NSString* shortcut = [self shortcutKeyForTag:[[bookmarkShortcutKey selectedItem] tag]];
    NSString* command = [bookmarkCommand stringValue];
    NSString* dir = [bookmarkDirectory stringValue];
    
    NSString* customCommand = [[bookmarkCommandType selectedCell] tag] == 0 ? @"Yes" : @"No";
    NSString* customDir;
    switch ([[bookmarkDirectoryType selectedCell] tag]) {
        case 0:
            customDir = @"Yes";
            break;
            
        case 2:
            customDir = @"Recycle";
            break;
            
        case 1:
        default:
            customDir = @"No";
            break;
    }
    
    if (sender == optionKeySends && [[optionKeySends selectedCell] tag] == OPT_META) {
        [self _maybeWarnAboutMeta];
    } else if (sender == rightOptionKeySends && [[rightOptionKeySends selectedCell] tag] == OPT_META) {
        [self _maybeWarnAboutMeta];
    }
    if (sender == spaceButton && [spaceButton selectedTag] > 0) {
        [self _maybeWarnAboutSpaces];
    }
    NSString* guid = [bookmarksTableView selectedGuid];
    if (!guid) {
        return;
    }
    Bookmark* origBookmark = [dataSource bookmarkWithGuid:guid];
    if (!origBookmark) {
        return;
    }
    NSMutableDictionary* newDict = [[NSMutableDictionary alloc] init];
    [newDict autorelease];
    NSString* isDefault = [origBookmark objectForKey:KEY_DEFAULT_BOOKMARK];
    if (!isDefault) {
        isDefault = @"No";
    }
    [newDict setObject:isDefault forKey:KEY_DEFAULT_BOOKMARK];
    [newDict setObject:name forKey:KEY_NAME];
    [newDict setObject:guid forKey:KEY_GUID];
    NSString* origGuid = [origBookmark objectForKey:KEY_ORIGINAL_GUID];
    if (origGuid) {
        [newDict setObject:origGuid forKey:KEY_ORIGINAL_GUID];
    }
    if (shortcut) {
        // If any bookmark has this shortcut, clear its shortcut.
        for (int i = 0; i < [dataSource numberOfBookmarks]; ++i) {
            Bookmark* temp = [dataSource bookmarkAtIndex:i];
            NSString* existingShortcut = [temp objectForKey:KEY_SHORTCUT];
            if ([shortcut length] > 0 && 
                [existingShortcut isEqualToString:shortcut] &&
                temp != origBookmark) {
                [dataSource setObject:nil forKey:KEY_SHORTCUT inBookmark:temp];
            }
        }
        
        [newDict setObject:shortcut forKey:KEY_SHORTCUT];
    }
    [newDict setObject:command forKey:KEY_COMMAND];
    [newDict setObject:dir forKey:KEY_WORKING_DIRECTORY];
    [newDict setObject:customCommand forKey:KEY_CUSTOM_COMMAND];
    [newDict setObject:customDir forKey:KEY_CUSTOM_DIRECTORY];
    
    // Colors tab
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi0Color color]] forKey:KEY_ANSI_0_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi1Color color]] forKey:KEY_ANSI_1_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi2Color color]] forKey:KEY_ANSI_2_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi3Color color]] forKey:KEY_ANSI_3_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi4Color color]] forKey:KEY_ANSI_4_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi5Color color]] forKey:KEY_ANSI_5_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi6Color color]] forKey:KEY_ANSI_6_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi7Color color]] forKey:KEY_ANSI_7_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi8Color color]] forKey:KEY_ANSI_8_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi9Color color]] forKey:KEY_ANSI_9_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi10Color color]] forKey:KEY_ANSI_10_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi11Color color]] forKey:KEY_ANSI_11_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi12Color color]] forKey:KEY_ANSI_12_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi13Color color]] forKey:KEY_ANSI_13_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi14Color color]] forKey:KEY_ANSI_14_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[ansi15Color color]] forKey:KEY_ANSI_15_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[foregroundColor color]] forKey:KEY_FOREGROUND_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[backgroundColor color]] forKey:KEY_BACKGROUND_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[boldColor color]] forKey:KEY_BOLD_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[selectionColor color]] forKey:KEY_SELECTION_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[selectedTextColor color]] forKey:KEY_SELECTED_TEXT_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[cursorColor color]] forKey:KEY_CURSOR_COLOR];
    [newDict setObject:[ITAddressBookMgr encodeColor:[cursorTextColor color]] forKey:KEY_CURSOR_TEXT_COLOR];
    [newDict setObject:[NSNumber numberWithBool:[checkColorInvertedCursor state]] forKey:KEY_SMART_CURSOR_COLOR];
    [newDict setObject:[NSNumber numberWithFloat:[minimumContrast floatValue]] forKey:KEY_MINIMUM_CONTRAST];
    
    [cursorColor setEnabled:[checkColorInvertedCursor state] == NSOffState];
    [cursorColorLabel setTextColor:([checkColorInvertedCursor state] == NSOffState) ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
    
    [cursorTextColor setEnabled:[checkColorInvertedCursor state] == NSOffState];
    [cursorTextColorLabel setTextColor:([checkColorInvertedCursor state] == NSOffState) ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
    
    // Display tab
    int rows, cols;
    rows = [rowsField intValue];
    cols = [columnsField intValue];
    if (cols > 0) {
        [newDict setObject:[NSNumber numberWithInt:cols] forKey:KEY_COLUMNS];
    }
    if (rows > 0) {
        [newDict setObject:[NSNumber numberWithInt:rows] forKey:KEY_ROWS];
    }
    [newDict setObject:[NSNumber numberWithInt:[windowTypeButton selectedTag]] forKey:KEY_WINDOW_TYPE];
    [self setScreens];
    [newDict setObject:[NSNumber numberWithInt:[screenButton selectedTag]] forKey:KEY_SCREEN];
    if ([spaceButton selectedTag]) {
        [newDict setObject:[NSNumber numberWithInt:[spaceButton selectedTag]] forKey:KEY_SPACE];
    }
    [newDict setObject:[ITAddressBookMgr descFromFont:normalFont] forKey:KEY_NORMAL_FONT];
    [newDict setObject:[ITAddressBookMgr descFromFont:nonAsciiFont] forKey:KEY_NON_ASCII_FONT];
    [newDict setObject:[NSNumber numberWithFloat:[displayFontSpacingWidth floatValue]] forKey:KEY_HORIZONTAL_SPACING];
    [newDict setObject:[NSNumber numberWithFloat:[displayFontSpacingHeight floatValue]] forKey:KEY_VERTICAL_SPACING];
    [newDict setObject:[NSNumber numberWithBool:([blinkingCursor state]==NSOnState)] forKey:KEY_BLINKING_CURSOR];
    [newDict setObject:[NSNumber numberWithBool:([blinkAllowed state]==NSOnState)] forKey:KEY_BLINK_ALLOWED];
    [newDict setObject:[NSNumber numberWithInt:[[cursorType selectedCell] tag]] forKey:KEY_CURSOR_TYPE];
    [newDict setObject:[NSNumber numberWithBool:([useBoldFont state]==NSOnState)] forKey:KEY_USE_BOLD_FONT];
    [newDict setObject:[NSNumber numberWithBool:([useBrightBold state]==NSOnState)] forKey:KEY_USE_BRIGHT_BOLD];
    [newDict setObject:[NSNumber numberWithFloat:[transparency floatValue]] forKey:KEY_TRANSPARENCY];
    [newDict setObject:[NSNumber numberWithBool:([blur state]==NSOnState)] forKey:KEY_BLUR];
    [newDict setObject:[NSNumber numberWithBool:([asciiAntiAliased state]==NSOnState)] forKey:KEY_ASCII_ANTI_ALIASED];
    [newDict setObject:[NSNumber numberWithBool:([nonasciiAntiAliased state]==NSOnState)] forKey:KEY_NONASCII_ANTI_ALIASED];
    [self _updateFontsDisplay];
    
    if (sender == backgroundImage) {
        NSString* filename = nil;
        if ([sender state] == NSOnState) {
            filename = [self _chooseBackgroundImage];
        }
        if (!filename) {
            [backgroundImagePreview setImage: nil];
            filename = @"";
        }
        backgroundImageFilename = filename;
    }
    [newDict setObject:backgroundImageFilename forKey:KEY_BACKGROUND_IMAGE_LOCATION];
    
    // Terminal tab
    [newDict setObject:[NSNumber numberWithBool:([disableWindowResizing state]==NSOnState)] forKey:KEY_DISABLE_WINDOW_RESIZING];
    [newDict setObject:[NSNumber numberWithBool:([syncTitle state]==NSOnState)] forKey:KEY_SYNC_TITLE];
    [newDict setObject:[NSNumber numberWithBool:([closeSessionsOnEnd state]==NSOnState)] forKey:KEY_CLOSE_SESSIONS_ON_END];
    [newDict setObject:[NSNumber numberWithBool:([nonAsciiDoubleWidth state]==NSOnState)] forKey:KEY_AMBIGUOUS_DOUBLE_WIDTH];
    [newDict setObject:[NSNumber numberWithBool:([silenceBell state]==NSOnState)] forKey:KEY_SILENCE_BELL];
    [newDict setObject:[NSNumber numberWithBool:([visualBell state]==NSOnState)] forKey:KEY_VISUAL_BELL];
    [newDict setObject:[NSNumber numberWithBool:([flashingBell state]==NSOnState)] forKey:KEY_FLASHING_BELL];
    [newDict setObject:[NSNumber numberWithBool:([xtermMouseReporting state]==NSOnState)] forKey:KEY_XTERM_MOUSE_REPORTING];
    [newDict setObject:[NSNumber numberWithBool:([disableSmcupRmcup state]==NSOnState)] forKey:KEY_DISABLE_SMCUP_RMCUP];
    [newDict setObject:[NSNumber numberWithBool:([scrollbackWithStatusBar state]==NSOnState)] forKey:KEY_SCROLLBACK_WITH_STATUS_BAR];
    [newDict setObject:[NSNumber numberWithBool:([bookmarkGrowlNotifications state]==NSOnState)] forKey:KEY_BOOKMARK_GROWL_NOTIFICATIONS];
    [newDict setObject:[NSNumber numberWithUnsignedInt:[[characterEncoding selectedItem] tag]] forKey:KEY_CHARACTER_ENCODING];
    [newDict setObject:[NSNumber numberWithInt:[scrollbackLines intValue]] forKey:KEY_SCROLLBACK_LINES];
    [newDict setObject:[NSNumber numberWithBool:([unlimitedScrollback state]==NSOnState)] forKey:KEY_UNLIMITED_SCROLLBACK];
    [scrollbackLines setEnabled:[unlimitedScrollback state]==NSOffState];
    if ([unlimitedScrollback state] == NSOnState) {
        [scrollbackLines setStringValue:@""];
    } else if (sender == unlimitedScrollback) {
        [scrollbackLines setStringValue:@"10000"];
    }
    
    [newDict setObject:[terminalType stringValue] forKey:KEY_TERMINAL_TYPE];
    [newDict setObject:[NSNumber numberWithBool:([sendCodeWhenIdle state]==NSOnState)] forKey:KEY_SEND_CODE_WHEN_IDLE];
    [newDict setObject:[NSNumber numberWithInt:[idleCode intValue]] forKey:KEY_IDLE_CODE];
    
    // Keyboard tab
    [newDict setObject:[origBookmark objectForKey:KEY_KEYBOARD_MAP] forKey:KEY_KEYBOARD_MAP];
    [newDict setObject:[NSNumber numberWithInt:[[optionKeySends selectedCell] tag]] forKey:KEY_OPTION_KEY_SENDS];
    [newDict setObject:[NSNumber numberWithInt:[[rightOptionKeySends selectedCell] tag]] forKey:KEY_RIGHT_OPTION_KEY_SENDS];
    [newDict setObject:[tags objectValue] forKey:KEY_TAGS];
    
    BOOL reloadKeyMappings = NO;
    if (sender == deleteSendsCtrlHButton) {
        // Resolve any conflict between key mappings and delete sends ^h by
        // modifying key mappings.
        [self _setDeleteKeyMapToCtrlH:[deleteSendsCtrlHButton state] == NSOnState
                           inBookmark:newDict];
        reloadKeyMappings = YES;
    } else {
        // If a keymapping for the delete key was added, make sure the
        // delete sends ^h checkbox is correct
        BOOL sendCH = [self _deleteSendsCtrlHInBookmark:newDict];
        [deleteSendsCtrlHButton setState:sendCH ? NSOnState : NSOffState];
    }
    // Epilogue
    [dataSource setBookmark:newDict withGuid:guid];
    [bookmarksTableView reloadData];
    if (reloadKeyMappings) {
        [keyMappings reloadData];
    }
    
    // Selectively update form fields.
    [self updateShortcutTitles];
    if (prefs) {
        [prefs setObject:[dataSource rawData] forKey: @"New Bookmarks"];
    }
}

- (IBAction)copyToProfile:(id)sender
{
    NSString* sourceGuid = [bookmarksTableView selectedGuid];
    if (!sourceGuid) {
        return;
    }
    Bookmark* sourceBookmark = [dataSource bookmarkWithGuid:sourceGuid];
    NSString* profileGuid = [sourceBookmark objectForKey:KEY_ORIGINAL_GUID];
    Bookmark* destination = [[BookmarkModel sharedInstance] bookmarkWithGuid:profileGuid];
    // TODO: changing color presets in cmd-i causes profileGuid=null.
    if (sourceBookmark && destination) {
        NSMutableDictionary* copyOfSource = [[sourceBookmark mutableCopy] autorelease];
        [copyOfSource setObject:profileGuid forKey:KEY_GUID];
        [copyOfSource removeObjectForKey:KEY_ORIGINAL_GUID];
        [copyOfSource setObject:[destination objectForKey:KEY_NAME] forKey:KEY_NAME];
        [[BookmarkModel sharedInstance] setBookmark:copyOfSource withGuid:profileGuid];
        
        // TODO: ***MOVE TO HELPER?
        [[PreferencePanelController sharedInstance] bookmarkTableSelectionDidChange:[PreferencePanelController sharedInstance]->bookmarksTableView];
        
        // Update existing sessions
        /*        int n = [[iTermController sharedInstance] numberOfTerminals];
         for (int i = 0; i < n; ++i) {
         PseudoTerminal* pty = [[iTermController sharedInstance] terminalAtIndex:i];
         
         [pty reloadBookmarks];
         }
         */      
        // Update user defaults
        [[NSUserDefaults standardUserDefaults] setObject:[[BookmarkModel sharedInstance] rawData]
                                                  forKey: @"New Bookmarks"];
    }
}


- (IBAction)bookmarkUrlSchemeHandlerChanged:(id)sender
{
    NSString* guid = [bookmarksTableView selectedGuid];
    NSString* scheme = [[bookmarkUrlSchemes selectedItem] title];
    if ([urlHandlersByGuid objectForKey:scheme]) {
        [self disconnectHandlerForScheme:scheme];
    } else {
        [self connectBookmarkWithGuid:guid toScheme:scheme];
    }
    [self _populateBookmarkUrlSchemesFromDict:[dataSource bookmarkWithGuid:guid]];
}

// - (IBAction)duplicateBookmark:(id)sender
// {
//     NSString* guid = [bookmarksTableView selectedGuid];
//     if (!guid) {
//         NSBeep();
//         return;
//     }
//     Bookmark* bookmark = [dataSource bookmarkWithGuid:guid];
//     NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithDictionary:bookmark];
//     NSString* newName = [NSString stringWithFormat:@"Copy of %@", [newDict objectForKey:KEY_NAME]];
    
//     [newDict setObject:newName forKey:KEY_NAME];
//     [newDict setObject:[BookmarkModel freshGuid] forKey:KEY_GUID];
//     [newDict setObject:@"No" forKey:KEY_DEFAULT_BOOKMARK];
//     [dataSource addBookmark:newDict];
//     [bookmarksTableView reloadData];
//     [bookmarksTableView selectRowByGuid:[newDict objectForKey:KEY_GUID]];
// }

@end

