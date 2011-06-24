//
//  PreferencesAppearanceHelper.m
//  iTerm
//
//  Created by shabble on 09/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import "PreferencesAppearanceHelper.h"

@implementation PreferencesAppearanceHelper

@synthesize model=model_;

- (id)initWithModel:(PreferencesModel *)prefsModel
{
    if ((self = [super init])) {
        self.model = prefsModel;
    }
    return self;
}

- (void)awakeFromNib
{
    NSLog(@"Appearances Helper awaking from Nib, with model: %@", self.model);
}

@end
