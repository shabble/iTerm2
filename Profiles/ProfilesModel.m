/*
 **  ProfilesModel.m, was ProfilesModel.m
 **  
 **  Created by George Nachman on 8/24/10.
 **  Refactored by Tom Feist on 14/6/11.
 **
 **  Project: iTerm2
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

#import "Prefs/PreferenceKeys.h"
#import "Profiles/ProfilesModel.h"

id gAltOpenAllRepresentedObject;

@implementation ProfilesModel

+ (void)initialize
{
    gAltOpenAllRepresentedObject = [[NSObject alloc] init];
}

- (ProfilesModel*)init
{
    profiles_ = [[NSMutableArray alloc] init];
    defaultProfileGuid_ = @"";
    journal_ = [[NSMutableArray alloc] init];
    return self;
}

+ (ProfilesModel*)sharedInstance
{
    static ProfilesModel* shared = nil;

    if (!shared) {
        shared = [[ProfilesModel alloc] init];
        shared->prefs_ = [NSUserDefaults standardUserDefaults];
        shared->postChanges_ = YES;
    }

    return shared;
}

+ (ProfilesModel*)sessionsInstance
{
    static ProfilesModel* shared = nil;

    if (!shared) {
        shared = [[ProfilesModel alloc] init];
        shared->prefs_ = nil;
        shared->postChanges_ = NO;
    }

    return shared;
}

- (void)dealloc
{
    [super dealloc];
    [journal_ release];
    NSLog(@"Deallocating bookmark model!");
}

- (int)numberOfProfiles
{
    return [profiles_ count];
}

- (BOOL)_document:(NSArray *)nameWords containsToken:(NSString *)token
{
    for (int k = 0; k < [nameWords count]; ++k) {
        NSString* tagPart = [nameWords objectAtIndex:k];
        NSRange range;
        if ([token length] && [token characterAtIndex:0] == '*') {
            range = [tagPart rangeOfString:[token substringFromIndex:1] options:NSCaseInsensitiveSearch];
        } else {
            range = [tagPart rangeOfString:token options:(NSCaseInsensitiveSearch | NSAnchoredSearch)];
        }
        if (range.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)doesProfileAtIndex:(int)theIndex matchFilter:(NSArray*)tokens
{
    Profile* bookmark = [self bookmarkAtIndex:theIndex];
    NSArray* tags = [bookmark objectForKey:KEY_TAGS];
    NSArray* nameWords = [[bookmark objectForKey:KEY_NAME] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (int i = 0; i < [tokens count]; ++i) {
        NSString* token = [tokens objectAtIndex:i];
        if (![token length]) {
            continue;
        }
        // Search each word in tag until one has this token as a prefix.
        bool found;

        // First see if this token occurs in the title
        found = [self _document:nameWords containsToken:token];

        // If not try each tag.
        for (int j = 0; !found && j < [tags count]; ++j) {
            // Expand the jth tag into an array of the words in the tag
            NSArray* tagWords = [[tags objectAtIndex:j] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            found = [self _document:tagWords containsToken:token];
        }
        if (!found) {
            // No tag had token i as a prefix.
            return NO;
        }
    }
    return YES;
}

- (NSArray*)parseFilter:(NSString*)filter
{
    return [filter componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSArray*)bookmarkIndicesMatchingFilter:(NSString*)filter
{
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[profiles_ count]];
    NSArray* tokens = [self parseFilter:filter];
    int count = [profiles_ count];
    for (int i = 0; i < count; ++i) {
        if ([self doesProfileAtIndex:i matchFilter:tokens]) {
            [result addObject:[NSNumber numberWithInt:i]];
        }
    }
    return result;
}

- (int)numberOfProfilesWithFilter:(NSString*)filter
{
    NSArray* tokens = [self parseFilter:filter];
    int count = [profiles_ count];
    int n = 0;
    for (int i = 0; i < count; ++i) {
        if ([self doesProfileAtIndex:i matchFilter:tokens]) {
            ++n;
        }
    }
    return n;
}

- (Profile*)bookmarkAtIndex:(int)i
{
    if (i < 0 || i >= [profiles_ count]) {
        return nil;
    }
    return [profiles_ objectAtIndex:i];
}

- (Profile*)bookmarkAtIndex:(int)theIndex withFilter:(NSString*)filter
{
    NSArray* tokens = [self parseFilter:filter];
    int count = [profiles_ count];
    int n = 0;
    for (int i = 0; i < count; ++i) {
        if ([self doesProfileAtIndex:i matchFilter:tokens]) {
            if (n == theIndex) {
                return [self bookmarkAtIndex:i];
            }
            ++n;
        }
    }
    return nil;
}

- (void)addProfile:(Profile*)bookmark
{
    [self addProfile:bookmark inSortedOrder:NO];
}

- (void)addProfile:(Profile*)bookmark inSortedOrder:(BOOL)sort
{

    NSMutableDictionary *newProfile = [[bookmark mutableCopy] autorelease];

    // Ensure required fields are present
    if (![newProfile objectForKey:KEY_NAME]) {
        [newProfile setObject:@"Profile" forKey:KEY_NAME];
    }
    if (![newProfile objectForKey:KEY_TAGS]) {
        [newProfile setObject:[NSArray arrayWithObjects:nil] forKey:KEY_TAGS];
    }
    if (![newProfile objectForKey:KEY_CUSTOM_COMMAND]) {
        [newProfile setObject:@"No" forKey:KEY_CUSTOM_COMMAND];
    }
    if (![newProfile objectForKey:KEY_COMMAND]) {
        [newProfile setObject:@"/bin/bash --login" forKey:KEY_COMMAND];
    }
    if (![newProfile objectForKey:KEY_GUID]) {
        [newProfile setObject:[ProfilesModel freshGuid] forKey:KEY_GUID];
    }
    if (![newProfile objectForKey:KEY_DEFAULT_BOOKMARK]) {
        [newProfile setObject:@"No" forKey:KEY_DEFAULT_BOOKMARK];
    }

    bookmark = [[newProfile copy] autorelease];

    int theIndex;
    if (sort) {
        // Insert alphabetically. Sort so that objects with the "bonjour" tag come after objects without.
        int insertionPoint = -1;
        NSString* newName = [bookmark objectForKey:KEY_NAME];
        BOOL hasBonjour = [self bookmark:bookmark hasTag:@"bonjour"];
        for (int i = 0; i < [profiles_ count]; ++i) {
            Profile* bookmarkAtI = [profiles_ objectAtIndex:i];
            NSComparisonResult order = NSOrderedSame;
            BOOL currentHasBonjour = [self bookmark:bookmarkAtI hasTag:@"bonjour"];
            if (hasBonjour != currentHasBonjour) {
                if (hasBonjour) {
                    order = NSOrderedAscending;
                } else {
                    order = NSOrderedDescending;
                }
            }
            if (order == NSOrderedSame) {
                order = [[[profiles_ objectAtIndex:i] objectForKey:KEY_NAME] caseInsensitiveCompare:newName];
            }
            if (order == NSOrderedDescending) {
                insertionPoint = i;
                break;
            }
        }
        if (insertionPoint == -1) {
            theIndex = [profiles_ count];
            [profiles_ addObject:[NSDictionary dictionaryWithDictionary:bookmark]];
        } else {
            theIndex = insertionPoint;
            [profiles_ insertObject:[NSDictionary dictionaryWithDictionary:bookmark] atIndex:insertionPoint];
        }
    } else {
        theIndex = [profiles_ count];
        [profiles_ addObject:[NSDictionary dictionaryWithDictionary:bookmark]];
    }
    NSString* isDeprecatedDefaultProfile = [bookmark objectForKey:KEY_DEFAULT_BOOKMARK];

    // The call to setDefaultByGuid may add a journal entry so make sure this one comes first.
    ProfileJournalEntry* e = [ProfileJournalEntry journalWithAction:JOURNAL_ADD bookmark:bookmark model:self];
    e->index = theIndex;
    [journal_ addObject:e];

    if (![self defaultProfile] || (isDeprecatedDefaultProfile && [isDeprecatedDefaultProfile isEqualToString:@"Yes"])) {
        [self setDefaultByGuid:[bookmark objectForKey:KEY_GUID]];
    }
    [self postChangeNotification];
}

- (BOOL)bookmark:(Profile*)bookmark hasTag:(NSString*)tag
{
    NSArray* tags = [bookmark objectForKey:KEY_TAGS];
    return [tags containsObject:tag];
}

- (int)convertFilteredIndex:(int)theIndex withFilter:(NSString*)filter
{
    NSArray* tokens = [self parseFilter:filter];
    int count = [profiles_ count];
    int n = 0;
    for (int i = 0; i < count; ++i) {
        if ([self doesProfileAtIndex:i matchFilter:tokens]) {
            if (n == theIndex) {
                return i;
            }
            ++n;
        }
    }
    return -1;
}

- (void)removeProfilesAtIndices:(NSArray*)indices
{
    NSArray* sorted = [indices sortedArrayUsingSelector:@selector(compare:)];
    for (int j = [sorted count] - 1; j >= 0; j--) {
        int i = [[sorted objectAtIndex:j] intValue];
        assert(i >= 0);

        [journal_ addObject:[ProfileJournalEntry journalWithAction:JOURNAL_REMOVE bookmark:[profiles_ objectAtIndex:i] model:self]];
        [profiles_ removeObjectAtIndex:i];
        if (![self defaultProfile] && [profiles_ count]) {
            [self setDefaultByGuid:[[profiles_ objectAtIndex:0] objectForKey:KEY_GUID]];
        }
    }
    [self postChangeNotification];
}

- (void)removeProfileAtIndex:(int)i
{
    assert(i >= 0);
    [journal_ addObject:[ProfileJournalEntry journalWithAction:JOURNAL_REMOVE bookmark:[profiles_ objectAtIndex:i] model:self]];
    [profiles_ removeObjectAtIndex:i];
    if (![self defaultProfile] && [profiles_ count]) {
        [self setDefaultByGuid:[[profiles_ objectAtIndex:0] objectForKey:KEY_GUID]];
    }
    [self postChangeNotification];
}

- (void)removeProfileAtIndex:(int)i withFilter:(NSString*)filter
{
    [self removeProfileAtIndex:[self convertFilteredIndex:i withFilter:filter]];
}

- (void)removeProfileWithGuid:(NSString*)guid
{
    int i = [self indexOfProfileWithGuid:guid];
    if (i >= 0) {
        [self removeProfileAtIndex:i];
    }
}

// A change in bookmarks is journal-worthy only if the name, shortcut, tags, or guid changes.
- (BOOL)bookmark:(Profile*)a differsJournalablyFrom:(Profile*)b
{
    // Any field that is shown in a view (profiles window, menus, bookmark list views, etc.) must
    // be a criteria for journalability for it to be updated immediately.
    if (![[a objectForKey:KEY_NAME] isEqualToString:[b objectForKey:KEY_NAME]] ||
        ![[a objectForKey:KEY_SHORTCUT] isEqualToString:[b objectForKey:KEY_SHORTCUT]] ||
        ![[a objectForKey:KEY_TAGS] isEqualToArray:[b objectForKey:KEY_TAGS]] ||
        ![[a objectForKey:KEY_GUID] isEqualToString:[b objectForKey:KEY_GUID]] ||
        ![[a objectForKey:KEY_COMMAND] isEqualToString:[b objectForKey:KEY_COMMAND]] ||
        ![[a objectForKey:KEY_CUSTOM_COMMAND] isEqualToString:[b objectForKey:KEY_CUSTOM_COMMAND]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setProfile:(Profile*)bookmark atIndex:(int)i
{
    Profile* orig = [profiles_ objectAtIndex:i];
    BOOL isDefault = NO;
    if ([[orig objectForKey:KEY_GUID] isEqualToString:defaultProfileGuid_]) {
        isDefault = YES;
    }

    Profile* before = [profiles_ objectAtIndex:i];
    BOOL needJournal = [self bookmark:bookmark differsJournalablyFrom:before];
    if (needJournal) {
        [journal_ addObject:[ProfileJournalEntry journalWithAction:JOURNAL_REMOVE bookmark:[profiles_ objectAtIndex:i] model:self]];
    }
    [profiles_ replaceObjectAtIndex:i withObject:bookmark];
    if (needJournal) {
        ProfileJournalEntry* e = [ProfileJournalEntry journalWithAction:JOURNAL_ADD bookmark:bookmark model:self];
        e->index = i;
        [journal_ addObject:e];
    }
    if (isDefault) {
        [self setDefaultByGuid:[bookmark objectForKey:KEY_GUID]];
    }
    if (needJournal) {
        [self postChangeNotification];
    }
}

- (void)setProfile:(Profile*)bookmark withGuid:(NSString*)guid
{
    int i = [self indexOfProfileWithGuid:guid];
    if (i >= 0) {
        [self setProfile:bookmark atIndex:i];
    }
}

- (void)removeAllProfiles
{
    [profiles_ removeAllObjects];
    defaultProfileGuid_ = @"";
    [journal_ addObject:[ProfileJournalEntry journalWithAction:JOURNAL_REMOVE_ALL bookmark:nil model:self]];
    [self postChangeNotification];
}

- (NSArray*)rawData
{
    return profiles_;
}

- (void)load:(NSArray*)prefs
{
    [profiles_ removeAllObjects];
    for (int i = 0; i < [prefs count]; ++i) {
        Profile* bookmark = [prefs objectAtIndex:i];
        NSArray* tags = [bookmark objectForKey:KEY_TAGS];
        if (![tags containsObject:@"bonjour"]) {
            [self addProfile:bookmark];
        }
    }
    [profiles_ retain];
}

+ (NSString*)freshGuid
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil); //create a new UUID
    //get the string representation of the UUID
    NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
}

- (int)indexOfProfileWithGuid:(NSString*)guid
{
    return [self indexOfProfileWithGuid:guid withFilter:@""];
}

- (int)indexOfProfileWithGuid:(NSString*)guid withFilter:(NSString*)filter
{
    NSArray* tokens = [self parseFilter:filter];
    int count = [profiles_ count];
    int n = 0;
    for (int i = 0; i < count; ++i) {
        if (![self doesProfileAtIndex:i matchFilter:tokens]) {
            continue;
        }
        if ([[[profiles_ objectAtIndex:i] objectForKey:KEY_GUID] isEqualToString:guid]) {
            return n;
        }
        ++n;
    }
    return -1;
}

- (Profile*)defaultProfile
{
    return [self bookmarkWithGuid:defaultProfileGuid_];
}

- (Profile*)bookmarkWithName:(NSString*)name
{
    int count = [profiles_ count];
    for (int i = 0; i < count; ++i) {
        if ([[[profiles_ objectAtIndex:i] objectForKey:KEY_NAME] isEqualToString:name]) {
            return [profiles_ objectAtIndex:i];
        }
    }
    return nil;
}

- (Profile*)bookmarkWithGuid:(NSString*)guid
{
    int count = [profiles_ count];
    for (int i = 0; i < count; ++i) {
        if ([[[profiles_ objectAtIndex:i] objectForKey:KEY_GUID] isEqualToString:guid]) {
            return [profiles_ objectAtIndex:i];
        }
    }
    return nil;
}

- (int)indexOfProfileWithName:(NSString*)name
{
    int count = [profiles_ count];
    for (int i = 0; i < count; ++i) {
        if ([[[profiles_ objectAtIndex:i] objectForKey:KEY_NAME] isEqualToString:name]) {
            return i;
        }
    }
    return -1;
}

- (NSArray*)allTags
{
    NSMutableDictionary* temp = [[[NSMutableDictionary alloc] init] autorelease];
    for (int i = 0; i < [self numberOfProfiles]; ++i) {
        Profile* bookmark = [self bookmarkAtIndex:i];
        NSArray* tags = [bookmark objectForKey:KEY_TAGS];
        for (int j = 0; j < [tags count]; ++j) {
            NSString* tag = [tags objectAtIndex:j];
            [temp setObject:@"" forKey:tag];
        }
    }
    return [temp allKeys];
}

- (Profile*)setObject:(id)object forKey:(NSString*)key inProfile:(Profile*)bookmark
{
    NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithDictionary:bookmark];
    if (object == nil) {
        [newDict removeObjectForKey:key];
    } else {
        [newDict setObject:object forKey:key];
    }
    NSString* guid = [bookmark objectForKey:KEY_GUID];
    Profile* newProfile = [NSDictionary dictionaryWithDictionary:newDict];
    [self setProfile:newProfile
             withGuid:guid];
    return newProfile;
}

- (void)setDefaultByGuid:(NSString*)guid
{
    [guid retain];
    [defaultProfileGuid_ release];
    defaultProfileGuid_ = guid;
    if (prefs_) {
        [prefs_ setObject:defaultProfileGuid_ forKey:KEY_DEFAULT_GUID];
    }
    [journal_ addObject:[ProfileJournalEntry journalWithAction:JOURNAL_SET_DEFAULT
                                                       bookmark:[self defaultProfile]
                                                          model:self]];
    [self postChangeNotification];
}

- (void)moveGuid:(NSString*)guid toRow:(int)destinationRow
{
    int sourceRow = [self indexOfProfileWithGuid:guid];
    if (sourceRow < 0) {
        return;
    }
    Profile* bookmark = [profiles_ objectAtIndex:sourceRow];
    [bookmark retain];
    [profiles_ removeObjectAtIndex:sourceRow];
    if (sourceRow < destinationRow) {
        destinationRow--;
    }
    [profiles_ insertObject:bookmark atIndex:destinationRow];
    [bookmark release];
}

- (void)rebuildMenus
{
    [journal_ addObject:[ProfileJournalEntry journalWithAction:JOURNAL_REMOVE_ALL bookmark:nil model:self]];
    int i = 0;
    for (Profile* p in profiles_) {
        ProfileJournalEntry* e = [ProfileJournalEntry journalWithAction:JOURNAL_ADD bookmark:p model:self];
        e->index = i++;
        [journal_ addObject:e];
    }
    [self postChangeNotification];
}

- (void)postChangeNotification
{
    if (postChanges_) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"iTermReloadAddressBook"
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:journal_ forKey:@"array"]];
    }
    [journal_ release];
    journal_ = [[NSMutableArray alloc] init];
}

- (void)dump
{
    for (int i = 0; i < [self numberOfProfiles]; ++i) {
        Profile* profile = [self profileAtIndex:i];
        NSLog(@"%d: %@ %@", i, [profile objectForKey:KEY_NAME], [profile objectForKey:KEY_GUID]);
    }
}

- (NSArray*)profiles
{
    return profiles_;
}

- (NSArray*)guids
{
    NSMutableArray* guids = [NSMutableArray arrayWithCapacity:[profiles_ count]];
    for (Profile* bookmark in profiles_) {
        [guids addObject:[bookmark objectForKey:KEY_GUID]];
    }
    return guids;
}

+ (NSMenu*)findOrCreateTagSubmenuInMenu:(NSMenu*)menu startingAtItem:(int)skip withName:(NSString*)name params:(JournalParams*)params
{
    NSArray* items = [menu itemArray];
    int pos = [menu numberOfItems];
    int N = pos;
    for (int i = skip; i < N; i++) {
        NSMenuItem* cur = [items objectAtIndex:i];
        if (![cur submenu] || [cur isSeparatorItem]) {
            pos = i;
            break;
        }
        int comp = [[cur title] caseInsensitiveCompare:name];
        if (comp == 0) {
            return [cur submenu];
        } else if (comp > 0) {
            pos = i;
            break;
        }
    }

    // Add menu item with submenu
    NSMenuItem* newItem = [[NSMenuItem alloc] initWithTitle:name action:nil keyEquivalent:@""];
    [newItem setSubmenu:[[NSMenu alloc] init]];
    [menu insertItem:newItem atIndex:pos];

    return [newItem submenu];
}

+ (void)addOpenAllToMenu:(NSMenu*)menu params:(JournalParams*)params
{
    // Add separator + open all menu items
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem* openAll = [menu addItemWithTitle:@"Open All" action:params->openAllSelector keyEquivalent:@""];
    [openAll setTarget:params->target];

    // Add alternate open all menu
    NSMenuItem* altOpenAll = [[NSMenuItem alloc] initWithTitle:@"Open All in New Window"
                                                        action:params->alternateOpenAllSelector
                                                 keyEquivalent:@""];
    [altOpenAll setTarget:params->target];
    [altOpenAll setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [altOpenAll setAlternate:YES];
    [altOpenAll setRepresentedObject:gAltOpenAllRepresentedObject];
    [menu addItem:altOpenAll];
}

+ (BOOL)menuHasOpenAll:(NSMenu*)menu
{
    NSArray* items = [menu itemArray];
    if ([items count] < 3) {
        return NO;
    }
    int n = [items count];
    return ([[items objectAtIndex:n-1] representedObject] == gAltOpenAllRepresentedObject);
}

- (int)positionOfProfile:(Profile *)p startingAtItem:(int)skip inMenu:(NSMenu*)menu
{
    // Find position of bookmark in menu
    NSString* name = [p objectForKey:KEY_NAME];
    int N = [menu numberOfItems];
    if ([ProfilesModel menuHasOpenAll:menu]) {
        N -= 3;
    }
    NSArray* items = [menu itemArray];
    int pos = N;
    for (int i = skip; i < N; i++) {
        NSMenuItem* cur = [items objectAtIndex:i];
        if ([cur isSeparatorItem]) {
            break;
        }
        if ([cur isHidden] || [cur submenu]) {
            continue;
        }
        if ([[cur title] caseInsensitiveCompare:name] > 0) {
            pos = i;
            break;
        }
    }

    return pos;
}

- (int)positionOfProfileWithIndex:(int)theIndex startingAtItem:(int)skip inMenu:(NSMenu*)menu
{
    // Find position of bookmark in menu
    int N = [menu numberOfItems];
    if ([ProfilesModel menuHasOpenAll:menu]) {
        N -= 3;
    }
    NSArray* items = [menu itemArray];
    int pos = N;
    for (int i = skip; i < N; i++) {
        NSMenuItem* cur = [items objectAtIndex:i];
        if ([cur isSeparatorItem]) {
            break;
        }
        if ([cur isHidden] || [cur submenu]) {
            continue;
        }
        if ([cur tag] > theIndex) {
            pos = i;
            break;
        }
    }

    return pos;
}

- (void)addProfile:(Profile*)b
             toMenu:(NSMenu*)menu
         atPosition:(int)pos
         withParams:(JournalParams*)params
        isAlternate:(BOOL)isAlternate
            withTag:(int)tag
{
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[b objectForKey:KEY_NAME]
                                                  action:isAlternate ? params->alternateSelector : params->selector
                                           keyEquivalent:@""];
    NSString* shortcut = [b objectForKey:KEY_SHORTCUT];
    if ([shortcut length]) {
        [item setKeyEquivalent:[shortcut lowercaseString]];
        [item setKeyEquivalentModifierMask:NSCommandKeyMask | NSControlKeyMask | (isAlternate ? NSAlternateKeyMask : 0)];
    } else if (isAlternate) {
        [item setKeyEquivalentModifierMask:NSAlternateKeyMask];
    }
    [item setAlternate:isAlternate];
    [item setTarget:params->target];
    [item setRepresentedObject:[[[b objectForKey:KEY_GUID] copy] autorelease]];
    [item setTag:tag];
    [menu insertItem:item atIndex:pos];
}

- (void)addProfile:(Profile *)b toMenu:(NSMenu*)menu startingAtItem:(int)skip withTags:(NSArray*)tags params:(JournalParams*)params atPos:(int)theIndex
{
    int pos;
    if (theIndex == -1) {
        // Add in sorted order
        pos = [self positionOfProfile:b startingAtItem:skip inMenu:menu];
    } else {
        pos = [self positionOfProfileWithIndex:theIndex startingAtItem:skip inMenu:menu];
    }

    if (![tags count]) {
        // Add item & alternate if no tags
        [self addProfile:b toMenu:menu atPosition:pos withParams:params isAlternate:NO withTag:theIndex];
        [self addProfile:b toMenu:menu atPosition:pos+1 withParams:params isAlternate:YES withTag:theIndex];
    }

    // Add to tag submenus
    for (NSString* tag in [NSSet setWithArray:tags]) {
        NSMenu* tagSubMenu = [ProfilesModel findOrCreateTagSubmenuInMenu:menu
                                                          startingAtItem:skip
                                                                withName:tag
                                                                  params:params];
        [self addProfile:b toMenu:tagSubMenu startingAtItem:0 withTags:nil params:params atPos:-1];
    }

    if ([menu numberOfItems] > skip + 2 && ![ProfilesModel menuHasOpenAll:menu]) {
        [ProfilesModel addOpenAllToMenu:menu params:params];
    }
}

+ (void)applyAddJournalEntry:(ProfileJournalEntry*)e toMenu:(NSMenu*)menu startingAtItem:(int)skip params:(JournalParams*)params
{
    ProfilesModel* model = e->model;
    Profile* b = [model bookmarkWithGuid:e->guid];
    if (!b) {
        return;
    }
    [model addProfile:b toMenu:menu startingAtItem:skip withTags:[b objectForKey:KEY_TAGS] params:params atPos:e->index];
}

+ (void)applyRemoveJournalEntry:(ProfileJournalEntry*)e toMenu:(NSMenu*)menu startingAtItem:(int)skip params:(JournalParams*)params
{
    int pos = [menu indexOfItemWithRepresentedObject:e->guid];
    if (pos != -1) {
        [menu removeItemAtIndex:pos];
        [menu removeItemAtIndex:pos];
    }

    // Remove bookmark from each tag it belongs to
    for (NSString* tag in e->tags) {
        NSMenuItem* item = [menu itemWithTitle:tag];
        NSMenu* submenu = [item submenu];
        if (submenu) {
            [ProfilesModel applyRemoveJournalEntry:e toMenu:submenu startingAtItem:0 params:params];
            if ([submenu numberOfItems] == 0) {
                [menu removeItem:item];
            }
        }
    }

    // Remove "open all" section if it's no longer needed.
    // [0, ..., skip-1, bm1, bm1alt, separator, open all, open all alternate]
    if (([ProfilesModel menuHasOpenAll:menu] && [menu numberOfItems] <= skip + 5)) {
        [menu removeItemAtIndex:[menu numberOfItems] - 1];
        [menu removeItemAtIndex:[menu numberOfItems] - 1];
        [menu removeItemAtIndex:[menu numberOfItems] - 1];
    }
}

+ (void)applyRemoveAllJournalEntry:(ProfileJournalEntry*)e toMenu:(NSMenu*)menu startingAtItem:(int)skip params:(JournalParams*)params
{
    while ([menu numberOfItems] > skip) {
        [menu removeItemAtIndex:[menu numberOfItems] - 1];
    }
}

+ (void)applySetDefaultJournalEntry:(ProfileJournalEntry*)e toMenu:(NSMenu*)menu startingAtItem:(int)skip params:(JournalParams*)params
{
}

+ (void)applyJournal:(NSDictionary*)journalDict toMenu:(NSMenu*)menu startingAtItem:(int)skip params:(JournalParams*)params
{
    NSArray* journal = [journalDict objectForKey:@"array"];
    for (ProfileJournalEntry* entry in journal) {
        switch (entry->action) {
            case JOURNAL_ADD:
                [ProfilesModel applyAddJournalEntry:entry toMenu:menu startingAtItem:skip params:params];
                break;

            case JOURNAL_REMOVE:
                [ProfilesModel applyRemoveJournalEntry:entry toMenu:menu startingAtItem:skip params:params];
                break;

            case JOURNAL_REMOVE_ALL:
                [ProfilesModel applyRemoveAllJournalEntry:entry toMenu:menu startingAtItem:skip params:params];
                break;

            case JOURNAL_SET_DEFAULT:
                [ProfilesModel applySetDefaultJournalEntry:entry toMenu:menu startingAtItem:skip params:params];
                break;

            default:
                assert(false);
        }
    }
}

+ (void)applyJournal:(NSDictionary*)journal toMenu:(NSMenu*)menu params:(JournalParams*)params
{
    [ProfilesModel applyJournal:journal toMenu:menu startingAtItem:0 params:params];
}


@end

@implementation ProfileJournalEntry


+ (ProfileJournalEntry*)journalWithAction:(JournalAction)action
                                  bookmark:(Profile*)bookmark
                                     model:(ProfilesModel*)model
{
    ProfileJournalEntry* entry = [[[ProfileJournalEntry alloc] init] autorelease];
    entry->action = action;
    entry->guid = [[bookmark objectForKey:KEY_GUID] copy];
    entry->model = model;
    entry->tags = [[NSArray alloc] initWithArray:[bookmark objectForKey:KEY_TAGS]];
    return entry;
}

- (void)dealloc
{
    [guid release];
    [tags release];
    [super dealloc];
}

@end
