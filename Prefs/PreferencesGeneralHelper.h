//
//  PreferencesGeneralHelper.h
//  iTerm2
//
//  Created by shabble on 08/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesModel.h"

@interface PreferencesGeneralHelper : NSViewController {
    IBOutlet PreferencesModel *model;
}

@property (nonatomic,readwrite,assign) PreferencesModel *model;

- (id)initWithModel:(PreferencesModel *)aModel;

- (IBAction)saveButtonPress:(id)sender;

@end
