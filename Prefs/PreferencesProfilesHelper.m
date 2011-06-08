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
@synthesize prefsModel;

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
    if ([[tableView selectedGuids] count] == 1) {
        PreferencePanelController *ctrl = [PreferencePanelController sharedInstance];
      [ctrl bookmarkSettingChanged:nil];
    }
}

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

