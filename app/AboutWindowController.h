//
//  AboutWindowController.h
//  iTerm
//
//  Created by shabble on 25/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController {
    IBOutlet NSTextField *version_;
    IBOutlet NSTextField *homepage_;
    IBOutlet NSTextField *bugreport_;
    IBOutlet NSTextField *credits_;
    
}

- (void)awakeFromNib;
- (IBAction)closeCurrentSession:(id)sender;
- (NSAttributedString*)createLinkTo:(NSString*)urlString
                          withTitle:(NSString*)title
                      andAttributes:(NSDictionary*)attributes;
- (void)mouseEntered:(NSEvent *)anEvent;

@end