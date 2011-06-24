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
@synthesize preferenceKeys=preferenceKeys_;
@synthesize toolTips=tooltips_;
@synthesize defaultValues=defaultValues_;


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
        NSString *preferencesSchemaPath = [[NSBundle mainBundle]
                                           pathForResource:@"UserPreferenceSchema" 
                                           ofType:@"plist"];

        // TODO: do we even need to store schema? Could throw it away after this parse.
        schema_ = [[PreferencesSchema alloc] initWithSchemaFromFile:preferencesSchemaPath];
        self.preferenceKeys = [schema_ preferenceKeysSet];
        self.toolTips       = [schema_ tooltipsDictionary];
        self.defaultValues  = [schema_ defaultValuesDictionary];

        resetInProgress_ = NO;
        self.userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        [self configureUserDefaults];
    }
    return self;
}

- (void)dealloc
{
    [self saveToUserPreferences];
    [self.preferenceKeys release];
    [self.defaultValues  release];
    [self.toolTips       release];

    [schema_ release];
    
    [super dealloc];
}

- (void)configureUserDefaults
{
    //  [self.userDefaultsController setAppliesImmediately:NO];
    [self.userDefaultsController setAppliesImmediately:YES];
    
    NSUserDefaults *defaults = [self.userDefaultsController defaults];

#ifdef DEBUG
    /* set the tooltip delay lower than default. Value in ms */
    [defaults setObject:[NSNumber numberWithInt:500] forKey:@"NSInitialToolTipDelay"];
#endif
    
    //[defaults setPersistentDomain:userDefaultsValuesDict forName:self.preferencesDomain];
    [defaults registerDefaults:self.defaultValues];
    [self.userDefaultsController setInitialValues:self.defaultValues];
    [self updateAllModelValues];
}

- (void)updateAllModelValues
{
    NSLog(@"PMODEL: Updating all Model Values");
    id values = [self values];
    for (NSString *str in [preferenceKeys_ allObjects]) {
        id value = [values valueForKey:str];
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
    NSLog(@"MODEL: save to user preferences");
    [self.userDefaultsController save:self];
}

- (void)loadFromUserPreferences
{
    NSLog(@"MODEL: load from user preferences");
    
    NSString *domain = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"bundle: %@", domain);
    NSDictionary *customPrefs 
        = [[self.userDefaultsController defaults] persistentDomainForName:domain];
    
    resetInProgress_ = YES;
    for (NSString *key in [customPrefs allKeys]) {
        id value = [customPrefs valueForKey:key];
        NSLog(@"loading key: %@ => %@", key, value);
        [self setValue:value forKey:key];
    }
    resetInProgress_ = NO;
}

- (id)values
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
    if ([preferenceKeys_ containsObject:key]) {
        return [[self values] valueForKey:key];        
    }
    
    /* special cases which redirect to the appropriate accessors */
    if ([key isEqual:@"toolTips"]) {
        return self.toolTips;
    }

    /* access to self is necessary for the NSObjectController bindings. */
    if ([key isEqual:@"self"]) {
        NSLog(@"PMODEL: Self requested");
        return self;
    }
    
    return [self valueForUndefinedKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    NSLog(@"setValue: %@ ForKey: %@", value, key);
    if ([preferenceKeys_ containsObject:key]) {
        NSLog(@"key: %@ is valid", key);
        id originalValue = [[self values] valueForKey:key];
        if ([originalValue isEqual:value] && ! resetInProgress_) {
            return;
        }
        NSLog(@"Values differ, going to update");
        [self willChangeValueForKey:key];
        [[self values] setValue:value forKey:key];
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
