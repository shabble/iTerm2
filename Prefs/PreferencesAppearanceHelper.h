//
//  PreferencesAppearanceHelper.h
//  iTerm
//
//  Created by shabble on 09/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesModel.h"

@interface PreferencesAppearanceHelper : NSViewController {
    IBOutlet PreferencesModel *model_;
}

@property (nonatomic,readwrite,assign) PreferencesModel *model;

- (id)initWithModel:(PreferencesModel *)prefsModel;

@end
