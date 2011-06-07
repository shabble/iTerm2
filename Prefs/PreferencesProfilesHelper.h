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
#import "Profiles/BookmarkModel.h"
#import "Profiles/BookmarkListView.h"
#import "Prefs/PreferencesModel.h"

@interface PreferencesProfilesHelper : NSObject <BookmarkTableDelegate> 
{
    BookmarkTableView *tableView;
    PreferencesModel *prefsModel;
}

@property (readwrite,retain) BookmarkTableView *tableView;
@property (readwrite,retain) PreferencesModel *prefsModel;

+ (id)initWithBookmarkTableView:(BookmarkTableView *)view;
//- (IBAction)duplicateBookmark:(id)sender;

@end
