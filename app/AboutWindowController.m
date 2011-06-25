//
//  AboutWindowController.m
//  iTerm
//
//  Created by shabble on 25/06/2011.
//  Copyright 2011 . All rights reserved.
//

#import "AboutWindowController.h"


@implementation AboutWindowController

- (NSAttributedString*)_linkTo:(NSString*)urlString
                         title:(NSString*)title
                withAttributes:(NSDictionary*)attributes
{
    NSDictionary *linkAttributes
        = [NSDictionary dictionaryWithObject:[NSURL URLWithString:urlString]
                                      forKey:NSLinkAttributeName];
    NSAttributedString *string 
        = [[NSAttributedString alloc] initWithString:title attributes:linkAttributes];
    
    return [string autorelease];
}

- (void)awakeFromNib
{
    NSLog(@"Awoken from nib (about window)");
    
    NSNumber *underlineStyle = [NSNumber numberWithInt: NSSingleUnderlineStyle];
    
    NSDictionary *linkTextViewAttributes
    = [NSDictionary dictionaryWithObjectsAndKeys:
       underlineStyle,                NSUnderlineStyleAttributeName,
       [NSColor blueColor],           NSForegroundColorAttributeName,
       [NSCursor pointingHandCursor], NSCursorAttributeName,
       nil];
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString 
    = [NSString stringWithFormat: @"Build %@", [infoDict objectForKey:@"CFBundleVersion"]];
    [version_ setStringValue:versionString];
    
    NSAttributedString *webAString     = [self _linkTo:@"http://iterm2.com/"
                                                 title:@"Home Page"
                                        withAttributes:linkTextViewAttributes];
    [homepage_ setAttributedStringValue:webAString];
    
    NSAttributedString *bugsAString    = [self _linkTo:@"http://code.google.com/p/iterm2/issues/entry"
                                                 title:@"Report a bug"
                                        withAttributes:nil];
    [bugreport_ setAttributedStringValue:bugsAString];
    
    NSAttributedString *creditsAString = [self _linkTo:@"http://code.google.com/p/iterm2/wiki/Credits"
                                                 title:@"Credits"
                                        withAttributes:nil];
    
    [credits_ setAttributedStringValue:creditsAString];
}

- (IBAction)closeCurrentSession:(id)sender
{
    [self close];
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
