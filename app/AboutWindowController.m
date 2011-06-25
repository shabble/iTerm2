//
//  AboutWindowController.m
//  iTerm
//
//  Created by shabble on 25/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import "AboutWindowController.h"


@implementation AboutWindowController

- (NSAttributedString*)createLinkTo:(NSString*)urlString
                          withTitle:(NSString*)title
                      andAttributes:(NSDictionary*)attributes
{
    NSMutableDictionary *linkAttributes = [attributes mutableCopy];
    NSURL *url = [NSURL URLWithString:urlString];

    [linkAttributes setObject:url
                       forKey:NSLinkAttributeName];

    NSAttributedString *string 
        = [[NSAttributedString alloc] initWithString:title attributes:linkAttributes];
    
    return [string autorelease];
}

- (void)awakeFromNib
{
    NSLog(@"Awoken from nib (about window)");
    
    NSNumber *underlineStyle = [NSNumber numberWithInt: NSSingleUnderlineStyle];

    NSMutableParagraphStyle *centeredTextStyle
        = [[NSMutableParagraphStyle alloc] init];
    [centeredTextStyle setAlignment:NSCenterTextAlignment];
    
    
    NSDictionary *linkTextViewAttributes
    = [NSDictionary dictionaryWithObjectsAndKeys:
       underlineStyle,                NSUnderlineStyleAttributeName,
       [NSColor blueColor],           NSForegroundColorAttributeName,
       [NSCursor pointingHandCursor], NSCursorAttributeName,
       centeredTextStyle,             NSParagraphStyleAttributeName,
       NULL];

    [centeredTextStyle release];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString 
        = [NSString stringWithFormat: @"Build %@",
            [infoDict objectForKey:@"CFBundleVersion"]];

    NSCursor *cross = [NSCursor crosshairCursor];
    [cross setOnMouseEntered:YES];
    [cross setOnMouseExited:YES];
        
    [version_ setStringValue:versionString];
    [version_ setDelegate:self];

    NSAttributedString *webAString = [self createLinkTo:@"http://iterm2.com/"
                                              withTitle:@"Home Page"
                                          andAttributes:linkTextViewAttributes];
    [homepage_ setAttributedStringValue:webAString];
    
    NSAttributedString *bugsAString = [self createLinkTo:@"http://code.google.com/p/iterm2/issues/entry"
                                               withTitle:@"Report a bug"
                                           andAttributes:linkTextViewAttributes];
    [bugreport_ setAttributedStringValue:bugsAString];

    
    NSMutableAttributedString *creditsAString = [[self createLinkTo:@"http://code.google.com/p/iterm2/wiki/Credits"
                                                          withTitle:@"Credits"
                                                      andAttributes:linkTextViewAttributes] mutableCopy];
  
    [credits_ setAttributedStringValue:creditsAString];
    
}

- (IBAction)closeCurrentSession:(id)sender
{
    [self close];
}

- (void)mouseEntered:(NSEvent *)anEvent
{
    NSLog(@"!!!!!!");
}

/*[AUTHORS setLinkTextAttributes:linkTextViewAttributes];
[[AUTHORS textStorage] deleteCharactersInRange: NSMakeRange(0, [[AUTHORS textStorage] length])];
[[AUTHORS textStorage] appendAttributedString:[[[NSAttributedString alloc] initWithString:versionString] autorelease]];
[[AUTHORS textStorage] appendAttributedString: webAString];
[[AUTHORS textStorage] appendAttributedString: bugsAString];
[[AUTHORS textStorage] appendAttributedString: creditsAString];
[AUTHORS setAlignment: NSCenterTextAlignment range: NSMakeRange(0, [[AUTHORS textStorage] length])];

aboutController = [[NSWindowController alloc] initWithWindow:ABOUT];
[aboutController showWindow:ABOUT];
*/
@end
