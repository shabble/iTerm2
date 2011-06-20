//
//  PreferencesGeneralHelper.m
//  iTerm2
//
//  Created by shabble on 08/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import "PreferencesGeneralHelper.h"


@implementation PreferencesGeneralHelper

@synthesize model;

- (id)initWithModel:(PreferencesModel *)aModel
{
    if ((self = [super init])) {
        model = aModel;
    }
    return self;
}

- (void)awakeFromNib
{
    NSLog(@"General Helper awaking from Nib, with modeL: %@", model);

}

- (IBAction)saveButtonPress:(id)sender;
{
    NSString *str = [self.model valueForKey:@"defaultString"];
    NSLog(@"Button pressed: %@", str);
}
@end
