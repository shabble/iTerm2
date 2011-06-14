// -*- mode:objc -*-
// $Id: iTermController.m,v 1.78 2008-10-17 04:02:45 yfabian Exp $
/*
 **  iTermController.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **      Initial code by Kiichi Kusama
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

// Debug option
#define DEBUG_ALLOC           0
#define DEBUG_METHOD_TRACE    0

#import <Carbon/Carbon.h>
#import "GTM/GTMCarbonEvent.h"

#import "App/iTermController.h"
#import "App/iTermApplicationDelegate.h"
#import "App/iTermApplication.h"
#import "App/KeyBindingManager.h"

#import "Prefs/PreferencePanelController.h"
#import "Profiles/ProfilesManager.h"

// Constants for saved window arrangement key names.
//static NSString* DEFAULT_ARRANGEMENT_NAME = @"Default";

static NSString* APPLICATION_SUPPORT_DIRECTORY = @"~/tmp/Library/Application Support";
static NSString *SUPPORT_DIRECTORY = @"~/Library/Application Support/iTerm";

// Comparator for sorting encodings
static NSInteger _compareEncodingByLocalizedName(id a, id b, void *unused)
{
    NSString *sa = [NSString localizedNameOfStringEncoding: [a unsignedIntValue]];
    NSString *sb = [NSString localizedNameOfStringEncoding: [b unsignedIntValue]];
    return [sa caseInsensitiveCompare: sb];
}


@implementation iTermController

static iTermController* shared = nil;
static BOOL initDone = NO;

+ (iTermController*)sharedInstance;
{
    if(!shared && !initDone) {
        shared = [[iTermController alloc] init];
        initDone = YES;
    }

    return shared;
}

+ (void)sharedInstanceRelease
{
    [shared release];
    shared = nil;
}

- (BOOL)hasWindowArrangement 
{
return NO; 
}

// init
- (id)init
{
#if DEBUG_ALLOC
    NSLog(@"%s(%d):-[iTermController init]",
          __FILE__, __LINE__);
#endif
    self = [super init];

 
    // create the iTerm directory if it does not exist
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // create the "~/Library/Application Support" directory if it does not exist
    if([fileManager fileExistsAtPath: [APPLICATION_SUPPORT_DIRECTORY stringByExpandingTildeInPath]] == NO)
        [fileManager createDirectoryAtPath: [APPLICATION_SUPPORT_DIRECTORY stringByExpandingTildeInPath] attributes: nil];

    if([fileManager fileExistsAtPath: [SUPPORT_DIRECTORY stringByExpandingTildeInPath]] == NO)
        [fileManager createDirectoryAtPath: [SUPPORT_DIRECTORY stringByExpandingTildeInPath] attributes: nil];

     return (self);
}

- (void) dealloc
{
#if DEBUG_ALLOC
    NSLog(@"%s(%d):-[iTermController dealloc]",
        __FILE__, __LINE__);
#endif
    // Close all terminal windows
    [super dealloc];
}



// meant for action for menu items that have a submenu
- (void) noAction: (id) sender
{

}


// Build sorted list of encodings
- (NSArray *) sortedEncodingList
{
    NSStringEncoding const *p;
    NSMutableArray *tmp = [NSMutableArray array];

    for (p = [NSString availableStringEncodings]; *p; ++p)
        [tmp addObject:[NSNumber numberWithUnsignedInt:*p]];
    [tmp sortUsingFunction: _compareEncodingByLocalizedName context:NULL];

    return (tmp);
}

- (void)_addProfile:(Profile*)profile
              toMenu:(NSMenu*)aMenu
              target:(id)aTarget
       withShortcuts:(BOOL)withShortcuts
            selector:(SEL)selector
   alternateSelector:(SEL)alternateSelector
{
    NSMenuItem* aMenuItem = [[NSMenuItem alloc] initWithTitle:[profile objectForKey:KEY_NAME]
                                                       action:selector
                                                keyEquivalent:@""];
    if (withShortcuts) {
        if ([profile objectForKey:KEY_SHORTCUT] != nil) {
            NSString* shortcut = [profile objectForKey:KEY_SHORTCUT];
            shortcut = [shortcut lowercaseString];
            [aMenuItem setKeyEquivalent:shortcut];
        }
    }

    unsigned int modifierMask = NSCommandKeyMask | NSControlKeyMask;
    [aMenuItem setKeyEquivalentModifierMask:modifierMask];
    [aMenuItem setRepresentedObject:[profile objectForKey:KEY_GUID]];
    [aMenuItem setTarget:aTarget];
    [aMenu addItem:aMenuItem];
    [aMenuItem release];

    if (alternateSelector) {
        aMenuItem = [[NSMenuItem alloc] initWithTitle:[profile objectForKey:KEY_NAME]
                                               action:alternateSelector
                                        keyEquivalent:@""];
        if (withShortcuts) {
            if ([profile objectForKey:KEY_SHORTCUT] != nil) {
                NSString* shortcut = [profile objectForKey:KEY_SHORTCUT];
                shortcut = [shortcut lowercaseString];
                [aMenuItem setKeyEquivalent:shortcut];
            }
        }

        modifierMask = NSCommandKeyMask | NSControlKeyMask;
        [aMenuItem setRepresentedObject:[profile objectForKey:KEY_GUID]];
        [aMenuItem setTarget:self];

        [aMenuItem setKeyEquivalentModifierMask:modifierMask | NSAlternateKeyMask];
        [aMenuItem setAlternate:YES];
        [aMenu addItem:aMenuItem];
        [aMenuItem release];
    }
}




- (void)addProfilesToMenu:(NSMenu *)aMenu withSelector:(SEL)selector openAllSelector:(SEL)openAllSelector startingAt:(int)startingAt
{
    JournalParams params;
    params.selector = selector;
    params.openAllSelector = openAllSelector;
    params.alternateSelector = @selector(newSessionInWindowAtIndex:);
    params.alternateOpenAllSelector = @selector(newSessionsInWindow:);
    params.target = self;

    ProfilesModel* pm = [ProfilesModel sharedInstance];
    int N = [pm numberOfProfiles];
    for (int i = 0; i < N; i++) {
        Profile* p = [pm profileAtIndex:i];
        [pm addProfile:p
                 toMenu:aMenu
         startingAtItem:startingAt
               withTags:[p objectForKey:KEY_TAGS]
                 params:&params
                  atPos:i];
    }
}

- (void)addProfilesToMenu:(NSMenu *)aMenu startingAt:(int)startingAt
{
    [self addProfilesToMenu:aMenu
                withSelector:@selector(newSessionInTabAtIndex:)
             openAllSelector:@selector(newSessionsInWindow:)
                  startingAt:startingAt];
}


+ (void)switchToSpaceInProfile:(Profile*)aDict
{
    if ([aDict objectForKey:KEY_SPACE]) {
        int spaceNum = [[aDict objectForKey:KEY_SPACE] intValue];
        if (spaceNum > 0 && spaceNum < 10) {
            // keycodes for digits 1-9. Send control-n to switch spaces.
            
            // TODO: This would get remapped by the event tap. It requires universal access to be on and
            // spaces to be configured properly. But we don't tell the users this.
            int codes[] = { 18, 19, 20, 21, 23, 22, 26, 28, 25 };
            CGEventRef e = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)codes[spaceNum - 1], true);
            CGEventSetFlags(e, kCGEventFlagMaskControl);
            CGEventPost(kCGSessionEventTap, e);
            CFRelease(e);

            e = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)codes[spaceNum - 1], false);
            CGEventSetFlags(e, kCGEventFlagMaskControl);
            CGEventPost(kCGSessionEventTap, e);
            CFRelease(e);
        }
    }
}


-(int)numberOfTerminals
{
    return 0;
}

- (void)rollInFinished
{
}

// http://www.cocoadev.com/index.pl?DeterminingOSVersion
+ (BOOL)getSystemVersionMajor:(unsigned *)major
                        minor:(unsigned *)minor
                       bugFix:(unsigned *)bugFix;
{
    OSErr err;
    SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
    if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) {
        return NO;
    }
    if (systemVersion < 0x1040) {
        if (major) {
            *major = ((systemVersion & 0xF000) >> 12) * 10 + ((systemVersion & 0x0F00) >> 8);
        }
        if (minor) {
            *minor = (systemVersion & 0x00F0) >> 4;
        }
        if (bugFix) {
            *bugFix = (systemVersion & 0x000F);
        }
    } else {
        if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) {
            return NO;
        }
        if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) {
            return NO;
        }
        if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) {
            return NO;
        }
        if (major) {
            *major = versionMajor;
        }
        if (minor) {
            *minor = versionMinor;
        }
        if (bugFix) {
            *bugFix = versionBugFix;
        }
    }
    
    return YES;
}




- (void)showNonHotKeyWindowsAndSetAlphaTo:(float)a
{
}

- (BOOL)rollingInHotkeyTerm
{
    return NO;
}

- (void)doNotOrderOutWhenHidingHotkeyWindow
{
    itermWasActiveWhenHotkeyOpened = YES;
}


- (void)unhide
{
}

- (void)showHotKeyWindow
{
}

- (BOOL)isHotKeyWindowOpen
{
    return NO;
}
void OnHotKeyEvent(void)
{
    NSLog(@"hotkey pressed");
    PreferencePanelController* prefPanel = [PreferencePanelController sharedInstance];
    if ([prefPanel hotkeyTogglesWindow]) {
        NSLog(@"visor enabled");
    } else if ([NSApp isActive]) {
        NSWindow* prefWindow = [prefPanel window];
        NSWindow* appKeyWindow = [[NSApplication sharedApplication] keyWindow];
        if (prefWindow != appKeyWindow ||
            ![iTermApplication isTextFieldInFocus:[prefPanel hotkeyField]]) {
            [NSApp hide:nil];
        }
    } else {
        //iTermController* controller = [iTermController sharedInstance];
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    }
}

- (BOOL)eventIsHotkey:(NSEvent*)e
{
    const int mask = (NSCommandKeyMask | NSAlternateKeyMask | NSShiftKeyMask | NSControlKeyMask);
    return (hotkeyCode_ &&
            ([e modifierFlags] & mask) == (hotkeyModifiers_ & mask) &&
            [e keyCode] == hotkeyCode_);
}




/*
 * The callback is passed a proxy for the tap, the event type, the incoming event,
 * and the refcon the callback was registered with.
 * The function should return the (possibly modified) passed in event,
 * a newly constructed event, or NULL if the event is to be deleted.
 *
 * The CGEventRef passed into the callback is retained by the calling code, and is
 * released after the callback returns and the data is passed back to the event
 * system.  If a different event is returned by the callback function, then that
 * event will be released by the calling code along with the original event, after
 * the event data has been passed back to the event system.
 */
static CGEventRef OnTappedEvent(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    iTermController* cont = refcon;
    if (type == kCGEventTapDisabledByTimeout) {
        NSLog(@"kCGEventTapDisabledByTimeout");
        if (cont->machPortRef) {
            NSLog(@"Re-enabling event tap");
            CGEventTapEnable(cont->machPortRef, true);
        }
        return NULL;
    } else if (type == kCGEventTapDisabledByUserInput) {
        NSLog(@"kCGEventTapDisabledByUserInput");
        if (cont->machPortRef) {
            NSLog(@"Re-enabling event tap");
            CGEventTapEnable(cont->machPortRef, true);
        }
        return NULL;
    }

    NSEvent* cocoaEvent = [NSEvent eventWithCGEvent:event];
    BOOL callDirectly = NO;
    BOOL local = NO;
    if ([NSApp isActive]) {
        // Remap modifier keys only while iTerm2 is active; otherwise you could just use the
        // OS's remap feature.
        NSString* unmodkeystr = [cocoaEvent charactersIgnoringModifiers];
        unichar unmodunicode = [unmodkeystr length] > 0 ? [unmodkeystr characterAtIndex:0] : 0;
        unsigned int modflag = [cocoaEvent modifierFlags];
        NSString *keyBindingText;
        PreferencePanelController* prefPanelController = [PreferencePanelController sharedInstance];
        PreferencesProfilesHelper* profilesHelper = [prefPanelController prefsProfilesHelper];
        BOOL tempDisabled = [profilesHelper remappingDisabledTemporarily];
        int action = [KeyBindingManager actionForKeyCode:unmodunicode
                                               modifiers:modflag
                                                    text:&keyBindingText
                                             keyMappings:nil];
        BOOL isDoNotRemap = (action == KEY_ACTION_DO_NOT_REMAP_MODIFIERS);
        local = action == KEY_ACTION_REMAP_LOCALLY;
        CGEventRef eventCopy = CGEventCreateCopy(event);
        if (local) {
            // The remapping should be applied and sent to [NSApp sendEvent:]
            // and not be returned from here. Apply the remapping to a copy
            // of the original event.
            CGEventRef temp = event;
            event = eventCopy;
            eventCopy = temp;
        }
        BOOL keySheetOpen = [[prefPanelController keySheet] isKeyWindow] && [prefPanelController keySheetIsOpen];
        if ((!tempDisabled && !isDoNotRemap) ||  // normal case, whether keysheet is open or not
            (!tempDisabled && isDoNotRemap && keySheetOpen)) {  // about to change dnr to non-dnr
            [KeyBindingManager remapModifiersInCGEvent:event
                                              prefPanel:prefPanelController];
            cocoaEvent = [NSEvent eventWithCGEvent:event];
        }
        if (local) {
            // Now that the cocoaEvent has the remapped version, restore
            // the original event.
            CGEventRef temp = event;
            event = eventCopy;
            eventCopy = temp;
        }
        CFRelease(eventCopy);
        if (tempDisabled && !isDoNotRemap) {
            callDirectly = YES;
        }
    } else {
        // Update cocoaEvent with a remapped modifier (if it appropriate to do
        // so). This has an effect only if the remapped key is the hotkey.
        CGEventRef eventCopy = CGEventCreateCopy(event);
        NSString* unmodkeystr = [cocoaEvent charactersIgnoringModifiers];
        unichar unmodunicode = [unmodkeystr length] > 0 ? [unmodkeystr characterAtIndex:0] : 0;
        unsigned int modflag = [cocoaEvent modifierFlags];
        NSString *keyBindingText;
        int action = [KeyBindingManager actionForKeyCode:unmodunicode
                                                       modifiers:modflag
                                                            text:&keyBindingText
                                                     keyMappings:nil];
        BOOL isDoNotRemap = (action == KEY_ACTION_DO_NOT_REMAP_MODIFIERS) || (action == KEY_ACTION_REMAP_LOCALLY);
        if (!isDoNotRemap) {
            [KeyBindingManager remapModifiersInCGEvent:eventCopy
                                              prefPanel:[PreferencePanelController sharedInstance]];
        }
        cocoaEvent = [NSEvent eventWithCGEvent:eventCopy];
        CFRelease(eventCopy);
    }
#ifdef USE_EVENT_TAP_FOR_HOTKEY
    if ([cont eventIsHotkey:cocoaEvent]) {
        OnHotKeyEvent();
        return NULL;
    }
#endif

    if (callDirectly) {
        // Send keystroke directly to preference panel when setting do-not-remap for a key; for
        // system keys, NSApp sendEvent: is never called so this is the last chance.
        [[PreferencePanelController sharedInstance] shortcutKeyDown:cocoaEvent];
        return nil;
    }
    if (local) {
        // Send event directly to iTerm2 and do not allow other apps to see the
        // event at all.
        [NSApp sendEvent:cocoaEvent];
        return nil;
    } else {
        // Normal case.
        return event;
    }
}

- (NSEvent*)runEventTapHandler:(NSEvent*)event
{
    CGEventRef newEvent = OnTappedEvent(nil, kCGEventKeyDown, [event CGEvent], self);
    if (newEvent) {
        return [NSEvent eventWithCGEvent:newEvent];
    } else {
        return nil;
    }
}

- (void)unregisterHotkey
{
    hotkeyCode_ = 0;
    hotkeyModifiers_ = 0;
#ifndef USE_EVENT_TAP_FOR_HOTKEY
    [[GTMCarbonEventDispatcherHandler sharedEventDispatcherHandler] unregisterHotKey:carbonHotKey_];
    [carbonHotKey_ release];
    carbonHotKey_ = nil;
#endif
}

- (BOOL)haveEventTap
{
    return machPortRef != 0;
}

- (void)stopEventTap
{
    if ([self haveEventTap]) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(),
                              eventSrc,
                              kCFRunLoopCommonModes);
        CFMachPortInvalidate(machPortRef); // switches off the event tap;
        CFRelease(machPortRef);
    }
}

- (BOOL)startEventTap
{
#ifdef FAKE_EVENT_TAP
    return YES;
#endif

    if (![self haveEventTap]) {
        DebugLog(@"Register event tap.");
        machPortRef = CGEventTapCreate(kCGHIDEventTap,
                                       kCGTailAppendEventTap,
                                       kCGEventTapOptionDefault,
                                       CGEventMaskBit(kCGEventKeyDown),
                                       (CGEventTapCallBack)OnTappedEvent,
                                       self);
        if (machPortRef) {
            eventSrc = CFMachPortCreateRunLoopSource(NULL, machPortRef, 0);
            if (eventSrc == NULL) {
                DebugLog(@"CFMachPortCreateRunLoopSource failed.");
                NSLog(@"CFMachPortCreateRunLoopSource failed.");
                CFRelease(machPortRef);
                machPortRef = 0;
                return NO;
            } else {
                DebugLog(@"Adding run loop source.");
                // Get the CFRunLoop primitive for the Carbon Main Event Loop, and add the new event souce
                CFRunLoopAddSource(CFRunLoopGetCurrent(),
                                   eventSrc,
                                   kCFRunLoopCommonModes);
                CFRelease(eventSrc);
            }
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}

- (BOOL)registerHotkey:(int)keyCode modifiers:(int)modifiers
{
    if (carbonHotKey_) {
        [self unregisterHotkey];
    }
    hotkeyCode_ = keyCode;
    hotkeyModifiers_ = modifiers & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSShiftKeyMask);
#ifdef USE_EVENT_TAP_FOR_HOTKEY
    if (![self startEventTap]) {
        switch (NSRunAlertPanel(@"Could not enable hotkey",
                                @"You have assigned a \"hotkey\" that opens iTerm2 at any time. To use it, you must turn on \"access for assistive devices\" in the Universal Access preferences panel in System Preferences and restart iTerm2.",
                                @"OK",
                                @"Open System Preferences",
                                @"Disable Hotkey",
                                nil)) {
            case NSAlertOtherReturn:
                [[PreferencePanel sharedInstance] disableHotkey];
                break;

            case NSAlertAlternateReturn:
                [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/UniversalAccessPref.prefPane"];
                return NO;
        }
    }
    return YES;
#else
    carbonHotKey_ = [[[GTMCarbonEventDispatcherHandler sharedEventDispatcherHandler]
                      registerHotKey:keyCode
                      modifiers:hotkeyModifiers_
                      target:self
                      action:@selector(carbonHotkeyPressed)
                      userInfo:nil
                      whenPressed:YES] retain];
    return YES;
#endif
}

- (void)carbonHotkeyPressed
{
    OnHotKeyEvent();
}

- (void)beginRemappingModifiers
{
    if (![self startEventTap]) {
        switch (NSRunAlertPanel(@"Could not remap modifiers",
                                @"You have chosen to remap certain modifier keys. For this to work for all key combinations (such as cmd-tab), you must turn on \"access for assistive devices\" in the Universal Access preferences panel in System Preferences and restart iTerm2.",
                                @"OK",
                                @"Open System Preferences",
                                nil,
                                nil)) {
            case NSAlertAlternateReturn:
                [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/UniversalAccessPref.prefPane"];
                break;
        }
    }
}

@end

