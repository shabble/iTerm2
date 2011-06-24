//
//  PreferencesGeneralHelper.m
//  iTerm2
//
//  Created by shabble on 08/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import "PreferencesGeneralHelper.h"


@implementation PreferencesGeneralHelper

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
    NSLog(@"General Helper awaking from Nib, with model: %@", self.model);

}

- (IBAction)saveButtonPress:(id)sender;
{
    NSString *str = [self.model valueForKey:@"defaultString"];
    NSLog(@"Button pressed: %@", str);
}
@end
