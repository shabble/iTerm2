/* -*- mode:objc -*-
 **
 **  PreferencesModel.m
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

#import "PreferencesModel.h"

@implementation PreferencesModel

@synthesize userDefaultsController=userDefaultsController_;
@synthesize validKeys=validKeys_;

+ (PreferencesModel*)sharedInstance;
{
    static PreferencesModel* shared = nil;
    if (!shared) {
        shared = [[self alloc] init];
        //shared->oneProfileMode = NO;
    }
    return shared;
}


- (id)init
{
    if ((self = [super init])) {
        NSString *preferencesSchemaPath = [[NSBundle mainBundle] pathForResource:@"UserPreferenceSchema" ofType:@"plist"];
        [self loadSchemaFromFile:preferencesSchemaPath];
        resetInProgress_ = NO;
        self.userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        [self configureUserDefaults];
    }
    return self;
}

- (void)dealloc
{
    [self saveToUserPreferences];
    [self.validKeys release];
    [super dealloc];
}

- (void)loadSchemaFromFile:(NSString*)theFile
{
    NSLog(@"Schema Filename: %@", theFile);
    NSDictionary *schemaDict = [NSDictionary dictionaryWithContentsOfFile:theFile];
    NSMutableSet *keys = [[NSMutableSet alloc] init];
    NSAssert(schemaDict != nil, @"User Preferences Schema is not nil");
    // TODO: Abstract these further? To #defines?
    NSArray *categories = [NSArray arrayWithObjects:@"General", @"Appearance", @"Profiles", @"GlobalKeyBinds", nil];
    for (NSString *categoryName in categories) {
        NSLog(@"processing category: %@", categoryName);
        NSDictionary *categoryDict = (NSDictionary *)[schemaDict valueForKey:categoryName];
        //NSLog(@" dict: %@ keys are: %@", categoryDict, [categoryDict allKeys]);
        [keys addObjectsFromArray:[categoryDict allKeys]];
    }
    self.validKeys = [[NSSet alloc] initWithSet:keys];
    NSLog(@"Keys loaded from schema: %@", self.validKeys);
    [keys release];
}

- (void)configureUserDefaults
{
    NSString       *userDefaultsValuesPath;
    NSDictionary   *userDefaultsValuesDict;
    NSUserDefaults *defaults;
    
//    [self.userDefaultsController setAppliesImmediately:NO];
    [self.userDefaultsController setAppliesImmediately:YES];
    
    // load the default values for the user defaults
    userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"AppDefaults"
                                                             ofType:@"plist"];
    userDefaultsValuesDict
    = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
    
    NSLog(@"PMODEL: configuring UserDefaults from %@", userDefaultsValuesPath);
    
    // set them in the standard user defaults
    defaults = [self.userDefaultsController defaults];
    //[defaults setPersistentDomain:userDefaultsValuesDict forName:self.preferencesDomain];
    [defaults registerDefaults:userDefaultsValuesDict];
    [self.userDefaultsController setInitialValues:userDefaultsValuesDict];
    [self updateAllModelValues];
}

- (void)updateAllModelValues
{
    NSLog(@"PMODEL: Updating all Model Values");
    id prefs = [self prefs];
    for (NSString *str in [validKeys_ allObjects]) {
        id value = [prefs valueForKey:str];
        NSLog(@"setting %@ to %@", str, value);
        [self setValue:value forKey:str];
    }
}

- (void)resetToFactoryDefaults
{   
    NSLog(@"MODEL: reset to AppDefault settings");
    
    [self.userDefaultsController revertToInitialValues:self];
    
    resetInProgress_ = YES;
    [self updateAllModelValues];
    resetInProgress_ = NO;
}

- (void)saveToUserPreferences
{
    NSLog(@"MODEL: save to user prefs");
    [self.userDefaultsController save:self];
}

- (void)loadFromUserPreferences
{
    NSLog(@"MODEL: load from user prefs");
    
    NSString *domain = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"bundle: %@", domain);
    NSDictionary *customPrefs = [[self.userDefaultsController defaults] persistentDomainForName:domain];
    resetInProgress_ = YES;
    for (NSString *key in [customPrefs allKeys]) {
        id value = [customPrefs valueForKey:key];
        NSLog(@"loading key: %@ => %@", key, value);
        [self setValue:value forKey:key];
    }
    resetInProgress_ = NO;
}

- (id)prefs
{
    return [self.userDefaultsController values];
}

- (NSDictionary*)initialValues
{
    return [self.userDefaultsController initialValues];
}

@end

@implementation PreferencesModel (KeyValueCoding)

- (id)valueForKey:(NSString*)key;
{
    if ([validKeys_ containsObject:key]) {
        return [[self prefs] valueForKey:key];
    } else if ([key isEqual:@"self"]) {
        // necessary for the NSObjectController bindings.
        NSLog(@"PMODEL: Self requested");
        return self;
    } else {
        return [self valueForUndefinedKey:key];
    }
    return nil;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    NSLog(@"setValue: %@ ForKey: %@", value, key);
    if ([validKeys_ containsObject:key]) {
        NSLog(@"key: %@ is valid", key);
        id originalValue = [[self prefs] valueForKey:key];
        if ([originalValue isEqual:value] && ! resetInProgress_) {
            return;
        }
        NSLog(@"Values differ, going to update");
        [self willChangeValueForKey:key];
        [[self prefs] setValue:value forKey:key];
        [self didChangeValueForKey:key];
    } else {
        NSLog(@"Invalid key: %@", key);
        [self setValue:value forUndefinedKey:key];
    }
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    return NO;
}

@end

/*
@implementation PreferencesModel

@synthesize  profileDataSource;
@synthesize  oneProfileMode;
@synthesize  defaultWindowStyle;
@synthesize  oneProfileOnly; 
@synthesize  defaultTabViewType;
@synthesize  defaultCopySelection;
@synthesize  defaultPasteFromClipboard;
@synthesize  defaultHideTab;
@synthesize  defaultPromptOnClose;
@synthesize  defaultPromptOnQuit;
@synthesize  defaultOnlyWhenMoreTabs;
@synthesize  defaultFocusFollowsMouse;
@synthesize  defaultWordChars;
@synthesize  defaultHotkeyTogglesWindow;
@synthesize  defaultHotKeyProfileGuid;
@synthesize  defaultEnableBonjour;
@synthesize  defaultCmdSelection;
@synthesize  defaultPassOnControlLeftClick;
@synthesize  defaultMaxVertically;
@synthesize  defaultClosingHotkeySwitchesSpaces;
@synthesize  defaultUseCompactLabel;
@synthesize  defaultHighlightTabLabels;
@synthesize  defaultAdvancedFontRendering;
@synthesize  defaultStrokeThickness;
@synthesize  defaultOpenProfile;
@synthesize  defaultQuitWhenAllWindowsClosed;
@synthesize  defaultCheckUpdate;
@synthesize  defaultColorInvertedCursor;
@synthesize  defaultDimInactiveSplitPanes;
@synthesize  defaultShowWindowBorder;
@synthesize  defaultHideScrollbar;
@synthesize  defaultSmartPlacement;
@synthesize  defaultFsTabDelay;
@synthesize  defaultWindowNumber;
@synthesize  defaultJobName;
@synthesize  defaultShowProfileName;
@synthesize  defaultInstantReplay;
@synthesize  defaultIrMemory;
@synthesize  defaultHotkey;
@synthesize  defaultHotkeyChar;
@synthesize  defaultHotkeyCode;
@synthesize  defaultHotkeyModifiers;
@synthesize  defaultSavePasteHistory;
@synthesize  defaultOpenArrangementAtStartup;
@synthesize  defaultCheckTestRelease;
@synthesize  prefs;
@synthesize  globalToolbarId;
@synthesize  appearanceToolbarId;
@synthesize  keyboardToolbarId;
@synthesize  profilesToolbarId;
@synthesize  urlHandlersByGuid;
@synthesize  backgroundImageFilename;
@synthesize  normalFont;
@synthesize  nonAsciiFont;
@synthesize  changingNAFont; 
@synthesize  keyString;  
@synthesize  newMapping;  
@synthesize  modifyMappingOriginator;  
@synthesize  defaultControl;
@synthesize  defaultLeftOption;
@synthesize  defaultRightOption;
@synthesize  defaultLeftCommand;
@synthesize  defaultRightCommand;
@synthesize  defaultSwitchTabModifier;
@synthesize  defaultSwitchWindowModifier;
 
@end
*/
