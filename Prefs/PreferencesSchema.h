//
//  PreferencesSchema.h
//  iTerm2
//
//  Created by shabble on 24/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define PREFERENCES_SCHEMA_CATEGORIES @"General", @"Appearance", @"Profiles", @"GlobalKeyBinds", nil

@interface PreferencesSchema : NSObject {

    NSDictionary *defaultValues_;
    NSDictionary *tooltips_;
    NSSet        *preferenceKeys_;
}

//@property (nonatomic,readwrite,retain) NSDictionary *schema;

- (id)initWithSchemaFromFile:(NSString*)file;
- (void)loadSchemaFromFile:(NSString*)file;
- (void)dealloc;


- (id)defaultValueForKey:(NSString*)key;
- (NSString*)tooltipForKey:(NSString*)key;
- (NSString*)commentForKey:(NSString*)key;

- (NSSet*)preferenceKeysSet;
- (NSDictionary*)tooltipsDictionary;
- (NSDictionary*)defaultValuesDictionary;

@end
