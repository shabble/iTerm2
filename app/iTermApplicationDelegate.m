// -*- mode:objc -*-
// $Id: iTermApplicationDelegate.m,v 1.70 2008-10-23 04:57:13 yfabian Exp $
/*
 **  iTermApplicationDelegate.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **          Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: Implements the main application delegate and handles the addressbook functions.
 **
 **  This program is free software; you can redistribute it and/or modify
 **  it under the terms of the GNU General Public License as published by
 **  the Free Software Foundation; either version 2 of the License, or
 **  (at your option) any later version.
 **
 **  This program is distributed in the hope that it will be useful,
 **  but WITHOUT ANY WARRANTY; without even the implied warranty of
 **  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 **  GNU General Public License for more details.
 **
 **  You should have received a copy of the GNU General Public License
 **  along with this program; if not, write to the Free Software
 **  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#import "App/iTermApplicationDelegate.h"
#import "App/iTermController.h"
#import "Prefs/PreferenceKeys.h"
#import "Prefs/PreferencePanelController.h"


#import "Profiles/ProfilesWindow.h"
#import "Profiles/ProfileManager.h"

#include <unistd.h>

NSMutableString* gDebugLogStr = nil;
NSMutableString* gDebugLogStr2 = nil;
//static BOOL usingAutoLaunchScript = NO;
BOOL gDebugLogging = NO;
int gDebugLogFile = -1;

@implementation iTermAboutWindow

- (IBAction)closeCurrentSession:(id)sender
{
    [self close];
}

@end


@implementation iTermApplicationDelegate

// NSApplication delegate methods
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    // Check the system version for minimum requirements.
    SInt32 gSystemVersion;
    Gestalt(gestaltSystemVersion, &gSystemVersion);
    if(gSystemVersion < 0x1020)
    {
                NSRunAlertPanel(NSLocalizedStringFromTableInBundle(@"Sorry",@"iTerm", [NSBundle bundleForClass: [iTermController class]], @"Sorry"),
                         NSLocalizedStringFromTableInBundle(@"Minimum_OS", @"iTerm", [NSBundle bundleForClass: [iTermController class]], @"OS Version"),
                        NSLocalizedStringFromTableInBundle(@"Quit",@"iTerm", [NSBundle bundleForClass: [iTermController class]], @"Quit"),
                         nil, nil);
                [NSApp terminate: self];
    }

    // set the TERM_PROGRAM environment variable
    putenv("TERM_PROGRAM=iTerm.app");
    NSLog(@"WillFinishLaunching");

        // read preferences
    [PreferencePanelController migratePreferences];
    [ProfileManager sharedInstance];
    [PreferencePanelController sharedInstance];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"DidFinishLaunching");
    /*
    // Prevent the input manager from swallowing control-q. See explanation here:
    // http://b4winckler.wordpress.com/2009/07/19/coercing-the-cocoa-text-system/
    CFPreferencesSetAppValue(CFSTR("NSQuotedKeystrokeBinding"),
                             CFSTR(""),
                             kCFPreferencesCurrentApplication);
    // This is off by default, but would wreack havoc if set globally.
    CFPreferencesSetAppValue(CFSTR("NSRepeatCountBinding"),
                             CFSTR(""),
                             kCFPreferencesCurrentApplication);

    PreferencePanelController* ppanel = [PreferencePanelController sharedInstance];
    if ([ppanel hotkey]) {
        [[iTermController sharedInstance] registerHotkey:[ppanel hotkeyCode] modifiers:[ppanel hotkeyModifiers]];
    }

    if ([ppanel isAnyModifierRemapped]) {
        [[iTermController sharedInstance] beginRemappingModifiers];
    }
    // register for services
    [NSApp registerServicesMenuSendTypes:[NSArray arrayWithObjects:NSStringPboardType, nil]
                                                       returnTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSStringPboardType, nil]];
    //[self showPrefWindow:self];
     */
    [[PreferencePanelController sharedInstance] run];

}

- (BOOL)applicationShouldTerminate: (NSNotification *) theNotification
{
    /*
    NSArray *terminals;

    //terminals = [[iTermController sharedInstance] terminals];

    // Display prompt if we need to
    
    int numTerminals = [terminals count];
    int numNontrivialWindows = numTerminals;
    BOOL promptOnQuit = quittingBecauseLastWindowClosed_ ? NO : (numNontrivialWindows > 0 && [[PreferencePanelController sharedInstance] promptOnQuit]);
    quittingBecauseLastWindowClosed_ = NO;
    BOOL promptOnClose = [[PreferencePanelController sharedInstance] promptOnClose];
    BOOL onlyWhenMoreTabs = [[PreferencePanelController sharedInstance] onlyWhenMoreTabs];
    int numTabs = 0;
    if (numTerminals > 0) {
        numTabs = [[[[iTermController sharedInstance] currentTerminal] tabView] numberOfTabViewItems];
    }
    BOOL shouldShowAlert = (!onlyWhenMoreTabs ||
                            numTerminals > 1 ||
                            numTabs > 1);
    if (promptOnQuit || (promptOnClose &&
                         numTerminals &&
                         shouldShowAlert)) {
        BOOL stayput = NSRunAlertPanel(@"Quit iTerm2?",
                                       @"All sessions will be closed",
                                       @"OK",
                                       @"Cancel",
                                       nil) != NSAlertDefaultReturn;
        if (stayput) {
            return NO;
        }
    }
    */
    // Ensure [iTermController dealloc] is called before prefs are saved
    NSLog(@"AppShouldTerminate");
    [[iTermController sharedInstance] stopEventTap];
    [iTermController sharedInstanceRelease];

    // save preferences
    [[PreferencePanelController sharedInstance] savePreferences];

    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSLog(@"AppWillTerminate");
    [[iTermController sharedInstance] stopEventTap];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    NSLog(@"openFile called");
    return NO;
    /*
        //NSLog(@"%s: %@", __PRETTY_FUNCTION__, filename);
        filename = [filename stringWithEscapedShellCharacters];
        if (filename) {
                // Verify whether filename is a script or a folder
                BOOL isDir;
                [[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDir];
                if (!isDir) {
                    //NSString *aString = [NSString stringWithFormat:@"%@; exit;\n", filename];
                    //[[iTermController sharedInstance] launchBookmark:nil inTerminal:nil];
                    // Sleeping a while waiting for the login.
                    //sleep(1);
                    //[[[[iTermController sharedInstance] currentTerminal] currentSession] insertText:aString];
                }
                else {
                        //NSString *aString = [NSString stringWithFormat:@"cd %@\n", filename];
                        //[[iTermController sharedInstance] launchBookmark:nil inTerminal:nil];
                        // Sleeping a while waiting for the login.
                        //sleep(1);
                        //[[[[iTermController sharedInstance] currentTerminal] currentSession] insertText:aString];
                }
        }
        return (YES);
     */
}



- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
    const double kMinRunningTime = 10;
    if ([[NSDate date] timeIntervalSinceDate:launchTime_] < kMinRunningTime) {
        return NO;
    }
    quittingBecauseLastWindowClosed_ = [[PreferencePanelController sharedInstance] quitWhenAllWindowsClosed];
    return quittingBecauseLastWindowClosed_;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    NSLog(@"ShouldHandleReopen callled");
    //PreferencePanelController* prefPanel = [PreferencePanelController sharedInstance];
  /*  if ([prefPanel hotkey] &&
        [prefPanel hotkeyTogglesWindow]) {
        // The hotkey window is configured.
       PseudoTerminal* hotkeyTerm = [[iTermController sharedInstance] hotKeyWindow];
        if (hotkeyTerm) {
            // Hide the existing window or open it if enabled by preference.
            if ([[hotkeyTerm window] alphaValue] == 1) {
                [[iTermController sharedInstance] hideHotKeyWindow:hotkeyTerm];
                return NO;
            } else if ([prefPanel dockIconTogglesWindow]) {
                [[iTermController sharedInstance] showHotKeyWindow];
                return NO;
            }
        } else if ([prefPanel dockIconTogglesWindow]) {
            // No existing hotkey window but preference is to toggle it by dock icon so open a new
            // one.
            [[iTermController sharedInstance] showHotKeyWindow];
            return NO;
        }
    } */
    return YES;
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification
{

}

// init
- (id)init
{
    self = [super init];

    // Add ourselves as an observer for notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadMenus:)
                                                 name:@"iTermWindowBecameKey"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateAddressBookMenu:)
                                                 name: @"iTermReloadAddressBook"
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(buildSessionSubmenu:)
                                                 name: @"iTermNumberOfSessionsDidChange"
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(buildSessionSubmenu:)
                                                 name: @"iTermNameOfSessionDidChange"
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadSessionMenus:)
                                                 name: @"iTermSessionBecameKey"
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nonTerminalWindowBecameKey:)
                                                 name:@"nonTerminalWindowBecameKey"
                                               object:nil];

    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(getUrl:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];

    aboutController = nil;
    launchTime_ = [[NSDate date] retain];

    NSLog(@"AppDelegate Done initing");
    return self;
}

- (void)awakeFromNib
{
    NSLog(@"awakeFromNib (MainMenu.xib)");
    //secureInputDesired_ = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Secure Input"] boolValue];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSLog(@"getURL called");
    /*
    NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSString *urlType = [url scheme];

    id bm = [[PreferencePanelController sharedInstance] handlerBookmarkForURL:urlType];
    if (bm) {
        [[iTermController sharedInstance] launchBookmark:bm
        inTerminal:[[iTermController sharedInstance] currentTerminal] withURL:urlStr];
    }
    */
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

- (IBAction)showPrefWindow:(id)sender
{
    NSLog(@"Going to open prefs window");
    [[PreferencePanelController sharedInstance] run];
    NSLog(@"Done opening prefs window");
}


static void SwapDebugLog() {
        NSMutableString* temp;
        temp = gDebugLogStr;
        gDebugLogStr = gDebugLogStr2;
        gDebugLogStr2 = temp;
}

static void FlushDebugLog() {
        NSData* data = [gDebugLogStr dataUsingEncoding:NSUTF8StringEncoding];
        int written = write(gDebugLogFile, [data bytes], [data length]);
        assert(written == [data length]);
        [gDebugLogStr setString:@""];
}



- (IBAction)toggleSecureInput:(id)sender
{
    // Set secureInputDesired_ to the opposite of the current state.
    secureInputDesired_ = [secureInput state] == NSOffState;

    // Try to set the system's state of secure input to the desired state.
    if (secureInputDesired_) {
        if (EnableSecureEventInput() != noErr) {
            NSLog(@"Failed to enable secure input.");
        }
    } else {
        if (DisableSecureEventInput() != noErr) {
            NSLog(@"Failed to disable secure input.");
        }
    }

    // Set the state of the control to the new true state.
    [secureInput setState:IsSecureEventInputEnabled() ? NSOnState : NSOffState];

    // Save the preference, independent of whether it succeeded or not.
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:secureInputDesired_]
                                              forKey:@"Secure Input"];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
    if (secureInputDesired_) {
        if (EnableSecureEventInput() != noErr) {
            NSLog(@"Failed to enable secure input.");
        }
    }
    // Set the state of the control to the new true state.
    [secureInput setState:IsSecureEventInputEnabled() ? NSOnState : NSOffState];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification
{
    if (secureInputDesired_) {
        if (DisableSecureEventInput() != noErr) {
            NSLog(@"Failed to disable secure input.");
        }
    }
    // Set the state of the control to the new true state.
    [secureInput setState:IsSecureEventInputEnabled() ? NSOnState : NSOffState];
}

// Debug logging
-(IBAction)debugLogging:(id)sender
{
        if (!gDebugLogging) {
                NSRunAlertPanel(@"Debug Logging Enabled",
                                                @"Writing to /tmp/debuglog.txt",
                                                @"OK", nil, nil);
                gDebugLogFile = open("/tmp/debuglog.txt", O_TRUNC | O_CREAT | O_WRONLY, S_IRUSR | S_IWUSR);
                gDebugLogStr = [[NSMutableString alloc] init];
                gDebugLogStr2 = [[NSMutableString alloc] init];
                gDebugLogging = !gDebugLogging;
        } else {
                gDebugLogging = !gDebugLogging;
                SwapDebugLog();
                FlushDebugLog();
                SwapDebugLog();
                FlushDebugLog();

                close(gDebugLogFile);
                gDebugLogFile=-1;
                NSRunAlertPanel(@"Debug Logging Stopped",
                                                @"Please compress and send /tmp/debuglog.txt to the developers.",
                                                @"OK", nil, nil);
                [gDebugLogStr release];
                [gDebugLogStr2 release];
        }
}

void DebugLog(NSString* value)
{
        if (gDebugLogging) {
                [gDebugLogStr appendString:value];
                [gDebugLogStr appendString:@"\n"];
                if ([gDebugLogStr length] > 100000000) {
                        SwapDebugLog();
                        [gDebugLogStr2 setString:@""];
                }
        }
}

/// About window

- (NSAttributedString *)_linkTo:(NSString *)urlString title:(NSString *)title
{
    NSDictionary *linkAttributes = [NSDictionary dictionaryWithObject:[NSURL URLWithString:urlString]
                                                               forKey:NSLinkAttributeName];
    NSString *localizedTitle = NSLocalizedStringFromTableInBundle(title, @"iTerm",
                                                                  [NSBundle bundleForClass:[self class]],
                                                                  @"About");

    NSAttributedString *string = [[NSAttributedString alloc] initWithString:localizedTitle
                                                                 attributes:linkAttributes];
    return [string autorelease];
}


- (IBAction)showAbout:(id)sender
{
    // check if an About window is shown already
    if (aboutController) {
        [aboutController showWindow:self];
        return;
    }

    NSDictionary *myDict = [[NSBundle bundleForClass:[self class]] infoDictionary];
    NSString *versionString = [NSString stringWithFormat: @"Build %@\n\n", [myDict objectForKey:@"CFBundleVersion"]];

    NSAttributedString *webAString = [self _linkTo:@"http://iterm2.com/" title:@"Home Page\n"];
    NSAttributedString *bugsAString = [self _linkTo:@"http://code.google.com/p/iterm2/issues/entry" title:@"Report a bug\n\n"];
    NSAttributedString *creditsAString = [self _linkTo:@"http://code.google.com/p/iterm2/wiki/Credits" title:@"Credits"];

    NSDictionary *linkTextViewAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt: NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
        [NSColor blueColor], NSForegroundColorAttributeName,
        [NSCursor pointingHandCursor], NSCursorAttributeName,
        NULL];

    [AUTHORS setLinkTextAttributes: linkTextViewAttributes];
    [[AUTHORS textStorage] deleteCharactersInRange: NSMakeRange(0, [[AUTHORS textStorage] length])];
    [[AUTHORS textStorage] appendAttributedString:[[[NSAttributedString alloc] initWithString:versionString] autorelease]];
    [[AUTHORS textStorage] appendAttributedString: webAString];
    [[AUTHORS textStorage] appendAttributedString: bugsAString];
    [[AUTHORS textStorage] appendAttributedString: creditsAString];
    [AUTHORS setAlignment: NSCenterTextAlignment range: NSMakeRange(0, [[AUTHORS textStorage] length])];

    aboutController = [[NSWindowController alloc] initWithWindow:ABOUT];
    [aboutController showWindow:ABOUT];
}




// Notifications
- (void)reloadMenus:(NSNotification *)aNotification
{
    return;
/*
    PseudoTerminal *frontTerminal = [self currentTerminal];
    if (frontTerminal != [aNotification object]) {
        return;
    }
    [previousTerminal setAction: (frontTerminal ? @selector(previousTerminal:) : nil)];
    [nextTerminal setAction: (frontTerminal ? @selector(nextTerminal:) : nil)];

    [self buildSessionSubmenu: aNotification];
    // reset the close tab/window shortcuts
    [closeTab setAction:@selector(closeCurrentTab:)];
    [closeTab setTarget:frontTerminal];
    [closeTab setKeyEquivalent:@"w"];
    [closeWindow setKeyEquivalent:@"W"];
    [closeWindow setKeyEquivalentModifierMask: NSCommandKeyMask];


    // set some menu item states
    if (frontTerminal && [[frontTerminal tabView] numberOfTabViewItems]) {
        [toggleBookmarksView setEnabled:YES];
        [sendInputToAllSessions setEnabled:YES];
        if ([frontTerminal sendInputToAllSessions] == YES) {
            [sendInputToAllSessions setState: NSOnState];
        } else {
            [sendInputToAllSessions setState: NSOffState];
        }
    } else {
        [toggleBookmarksView setEnabled:NO];
        [sendInputToAllSessions setEnabled:NO];
    }*/
}

- (void) nonTerminalWindowBecameKey: (NSNotification *) aNotification
{
    [closeTab setAction:nil];
    [closeTab setKeyEquivalent:@""];
    [closeWindow setKeyEquivalent:@"w"];
    [closeWindow setKeyEquivalentModifierMask:NSCommandKeyMask];
}



- (void)updateAddressBookMenu:(NSNotification*)aNotification
{
    JournalParams params;
    params.selector = @selector(newSessionInTabAtIndex:);
    params.openAllSelector = @selector(newSessionsInWindow:);
    params.alternateSelector = @selector(newSessionInWindowAtIndex:);
    params.alternateOpenAllSelector = @selector(newSessionsInWindow:);
    params.target = [iTermController sharedInstance];

    [ProfileModel applyJournal:[aNotification userInfo]
                         toMenu:bookmarkMenu
                 startingAtItem:5
                         params:&params];
}



- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    return NO;
}

@end







