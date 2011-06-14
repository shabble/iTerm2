/*
 **  BookmarkModel.h
 **  iTerm
 **
 **  Created by George Nachman on 8/24/10.
 **  Project: iTerm
 **
 **  Description: Model for an ordered collection of bookmarks. Profiles have
 **    numerous attributes, but always have a name, set of tags, and a guid.
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

#define BMKEY_BOOKMARKS_ARRAY @"Bookmarks Array"

typedef NSDictionary Profile;
typedef struct {
    SEL selector;                  // normal action
    SEL alternateSelector;         // opt+click
    SEL openAllSelector;           // open all bookmarks
    SEL alternateOpenAllSelector;  // opt+open all bookmarks
    id target;                     // receiver of selector
} JournalParams;

@interface ProfilesModel : NSObject {
    NSMutableArray* profiles_;
    NSString* defaultProfileGuid_;

    // The journal is an array of actions since the last change notification was
    // posted.
    NSMutableArray* journal_;
    NSUserDefaults* prefs_;          // TODO: move this to PreferencesModel.
    BOOL postChanges_;              // should change notifications be posted?
}

+ (ProfilesModel*)sharedInstance;
+ (ProfilesModel*)sessionsInstance;
+ (NSString*)freshGuid;

- (int)numberOfProfiles;
- (int)numberOfProfilesWithFilter:(NSString*)filter;
- (NSArray*)profileIndicesMatchingFilter:(NSString*)filter;
- (int)indexOfProfileWithGuid:(NSString*)guid;
- (int)indexOfProfileWithGuid:(NSString*)guid withFilter:(NSString*)filter;
- (Profile*)profileAtIndex:(int)index;
- (Profile*)profileAtIndex:(int)index withFilter:(NSString*)filter;
- (void)addProfile:(Profile*)profile;
- (void)addProfile:(Profile*)profile inSortedOrder:(BOOL)sort;
- (void)removeProfileWithGuid:(NSString*)guid;
- (void)removeProfilesAtIndices:(NSArray*)indices;
- (void)removeProfileAtIndex:(int)index;
- (void)removeProfileAtIndex:(int)index withFilter:(NSString*)filter;
- (void)setProfile:(Profile*)profile atIndex:(int)index;
- (void)setProfile:(Profile*)profile withGuid:(NSString*)guid;
- (void)removeAllProfiles;
- (NSArray*)rawData;
- (void)load:(NSArray*)prefs;
- (Profile*)defaultProfile;
- (Profile*)profileWithName:(NSString*)name;
- (Profile*)profileWithGuid:(NSString*)guid;
- (int)indexOfProfileWithName:(NSString*)name;
- (NSArray*)allTags;
- (BOOL)profile:(Profile*)profile hasTag:(NSString*)tag;
- (Profile*)setObject:(id)object forKey:(NSString*)key inProfile:(Profile*)profile;
- (void)setDefaultByGuid:(NSString*)guid;
- (void)moveGuid:(NSString*)guid toRow:(int)row;
- (void)rebuildMenus;
// Return the absolute index of a profile given its index with the filter applied.
- (int)convertFilteredIndex:(int)theIndex withFilter:(NSString*)filter;
- (void)dump;
- (NSArray*)profiles;
- (NSArray*)guids;
- (void)addProfile:(Profile*)profile toMenu:(NSMenu*)menu startingAtItem:(int)skip withTags:(NSArray*)tags params:(JournalParams*)params atPos:(int)pos;

// Tell all listeners that the model has changed.
- (void)postChangeNotification;

+ (void)applyJournal:(NSDictionary*)journal
              toMenu:(NSMenu*)menu
      startingAtItem:(int)skip
              params:(JournalParams*)params;

+ (void)applyJournal:(NSDictionary*)journal
              toMenu:(NSMenu*)menu
              params:(JournalParams*)params;

@end

typedef enum {
    JOURNAL_ADD,
    JOURNAL_REMOVE,
    JOURNAL_REMOVE_ALL,
    JOURNAL_SET_DEFAULT
} JournalAction;

@interface ProfileJournalEntry : NSObject {
  @public
    JournalAction action;
    NSString* guid;
    ProfilesModel* model;
    // Tags before the action was applied.
    NSArray* tags;
    int index;  // Index of bookmark
}

+ (ProfileJournalEntry*)journalWithAction:(JournalAction)action profile:(Profile*)profile model:(ProfilesModel*)model;

@end
