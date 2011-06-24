//
//  PreferencesSchema.m
//  iTerm
//
//  Created by shabble on 24/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import "PreferencesSchema.h"

@implementation PreferencesSchema

//@synthesize schema=schemaData_;

/* designated initialiser. */
- (id)initWithSchemaFromFile:(NSString*)file
{
    if ((self = [super init])) {
        [self loadSchemaFromFile:file];
    }
    return self;
}

- (void)dealloc
{
    [preferenceKeys_ release];
    [defaultValues_  release];
    [tooltips_       release];

    [super dealloc];
}
- (void)loadSchemaFromFile:(NSString*)file
{
    NSLog(@"Loading schema from file: %@", file);
    NSDictionary *schemaDict = [NSDictionary dictionaryWithContentsOfFile:file];
    NSArray *categories      = [NSArray arrayWithObjects:PREFERENCES_SCHEMA_CATEGORIES];
    
    NSAssert(schemaDict != nil, @"User Preferences Schema cannot be nil");
    
    NSMutableSet        *keys     = [[NSMutableSet alloc] init];
    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tooltips = [[NSMutableDictionary alloc] init];

    for (NSString *categoryName in categories) {
        NSLog(@"processing category: %@", categoryName);
        NSDictionary *categoryDict = (NSDictionary *)[schemaDict valueForKey:categoryName];

        [keys addObjectsFromArray:[categoryDict allKeys]];
        
        for (NSString *prefKey in [categoryDict allKeys]) {
            NSDictionary *prefKeyDict = (NSDictionary *)[categoryDict valueForKey:prefKey];

            NSString *tooltip = (NSString *)[prefKeyDict valueForKey:@"tooltip"];
            NSObject *defaultValue = [prefKeyDict valueForKey:@"default"];

            [tooltips setObject:tooltip forKey:prefKey];
            [defaults setObject:defaultValue forKey:prefKey];
        }
        //NSLog(@" dict: %@ keys are: %@", categoryDict, [categoryDict allKeys]);
    }
    NSLog(@"Tooltips keys: %@", [tooltips allKeys]);        
    /* copy the values into immutable instances for our ivars */
    preferenceKeys_ = [[NSSet alloc] initWithSet:keys];
    defaultValues_  = [[NSDictionary alloc] initWithDictionary:defaults];
    tooltips_       = [[NSDictionary alloc] initWithDictionary:tooltips];

    NSLog(@"Keys loaded from schema: %@", preferenceKeys_);

    /* and release the mutable temps */
    [keys     release];
    [defaults release];
    [tooltips release];
}

- (NSString*)tooltipForKey:(NSString*)key
{
    return [tooltips_ valueForKey:key];
}

- (id)defaultValueForKey:(NSString*)key
{
    return [defaultValues_ valueForKey:key];;
}

- (NSString*)commentForKey:(NSString*)key
{
    return @"NOT IMPLEMENTED";
}

- (NSDictionary*)defaultValuesDictionary
{
    return defaultValues_;
}

- (NSDictionary*)tooltipsDictionary
{
    return tooltips_;
}

- (NSSet*)preferenceKeysSet
{
    return preferenceKeys_;
}

@end
