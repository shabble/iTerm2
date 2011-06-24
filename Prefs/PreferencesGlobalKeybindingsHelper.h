//
//  PreferencesGlobalKeybindingsHelper.h
//  iTerm
//
//  Created by shabble on 09/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesModel.h"

@interface PreferencesGlobalKeybindingsHelper : NSViewController {
    
    IBOutlet PreferencesModel *model_;
    
    // Keyboard ------------------------------
 /*   int defaultControl;
    IBOutlet NSPopUpButton* controlButton;
    int defaultLeftOption;
    IBOutlet NSPopUpButton* leftOptionButton;
    int defaultRightOption;
    IBOutlet NSPopUpButton* rightOptionButton;
    int defaultLeftCommand;
    IBOutlet NSPopUpButton* leftCommandButton;
    int defaultRightCommand;
    IBOutlet NSPopUpButton* rightCommandButton;
    
    int defaultSwitchTabModifier;
    IBOutlet NSPopUpButton* switchTabModifierButton;
    int defaultSwitchWindowModifier;
    IBOutlet NSPopUpButton* switchWindowModifierButton;
    
    IBOutlet NSButton* deleteSendsCtrlHButton;
    
    IBOutlet NSTableView* globalKeyMappings;
    IBOutlet NSTableColumn* globalKeyCombinationColumn;
    IBOutlet NSTableColumn* globalActionColumn;
    IBOutlet NSButton* globalRemoveMappingButton;
    IBOutlet NSButton* globalAddNewMapping;
  */
}

@property (nonatomic,readwrite,assign) PreferencesModel *model;

- (id)initWithModel:(PreferencesModel *)prefsModel;

@end
