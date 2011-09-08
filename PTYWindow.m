/* -*- mode:objc -*- */
/* $Id: PTYWindow.m,v 1.17 2008-09-24 22:35:39 yfabian Exp $ */
/* Incorporated into iTerm.app by Ujwal S. Setlur */
/*
 **  PTYWindow.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **      Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: NSWindow subclass. Implements transparency.
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

#import <iTerm/iTerm.h>
#import <iTerm/PTYWindow.h>
#import <iTerm/PreferencePanel.h>
#import <iTerm/PseudoTerminal.h>
#import <iTerm/iTermController.h>
// This is included because the blurring code uses undocumented APIs to do its thing.
#import <CGSInternal.h>

#define DEBUG_METHOD_ALLOC  0
#define DEBUG_METHOD_TRACE  0
#define DEBUG_WINDOW_LAYOUT 0

#ifdef PSEUDOTERMINAL_VERBOSE_LOGGING
#define PtyLog NSLog
#else
#define PtyLog(args...)
#endif

@implementation PTYWindow

- (void) dealloc
{
#if DEBUG_METHOD_ALLOC
    NSLog(@"%s: 0x%x", __PRETTY_FUNCTION__, self);
#endif

    [super dealloc];

}

- initWithContentRect:(NSRect)contentRect
            styleMask:(NSUInteger)aStyle
              backing:(NSBackingStoreType)bufferingType
                defer:(BOOL)flag;
{
#if DEBUG_METHOD_ALLOC
    NSLog(@"%s: 0x%x", __PRETTY_FUNCTION__, self);
#endif

    if ((self = [super initWithContentRect:contentRect
                 styleMask:aStyle
                   backing:bufferingType
                     defer:flag]) != nil) {
        [self setAlphaValue:0.9999];
        blurFilter = 0;
        layoutDone = NO;
    }

    return self;
}
typedef CGError CGSSetWindowBackgroundBlurRadiusFunction(CGSConnectionID cid, CGSWindowID wid, NSUInteger blur);

static void *GetFunctionByName(NSString *library, char *func) {
    CFBundleRef bundle;
    CFURLRef bundleURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef) library, kCFURLPOSIXPathStyle, true);
    CFStringRef functionName = CFStringCreateWithCString(kCFAllocatorDefault, func, kCFStringEncodingASCII);    
    bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL);
    if (!bundle) {
        return NULL;
    }
    void *f = CFBundleGetFunctionPointerForName(bundle, functionName);
    CFRelease(functionName);
    CFRelease(bundleURL);
    CFRelease(bundle);
    return f;
}

static CGSSetWindowBackgroundBlurRadiusFunction* GetCGSSetWindowBackgroundBlurRadiusFunction() {
    static BOOL tried = NO;
    static CGSSetWindowBackgroundBlurRadiusFunction *function = NULL;
    if (!tried) {
        function  = GetFunctionByName(@"/System/Library/Frameworks/ApplicationServices.framework",
                                      "CGSSetWindowBackgroundBlurRadius");
    }
    return function;
}

- (void)enableBlur:(double)radius
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
    // Only works in Leopard (or hopefully later)
    if (!OSX_LEOPARDORLATER) return;

    const double kEpsilon = 0.001;
    if (blurFilter && fabs(blurRadius_ - radius) < kEpsilon) {
        return;
    }

    CGSConnectionID con = CGSMainConnectionID();
    if (!con) {
        return;
    }
    CGSSetWindowBackgroundBlurRadiusFunction* function = GetCGSSetWindowBackgroundBlurRadiusFunction();
    if (function) {
        // If CGSSetWindowBackgroundBlurRadius() is available (10.6 and up) use it because it works
        // right in Expos�.
        function(con, [self windowNumber], (int)radius);
    } else {
        // Fall back to 10.5-only method.
        if (CGSNewCIFilterByName(con, (CFStringRef)@"CIGaussianBlur", &blurFilter)) {
            return;
        }

        NSDictionary *optionsDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
        CGSSetCIFilterValuesFromDictionary(con, blurFilter, (CFDictionaryRef)optionsDict);

        CGSAddWindowFilter(con, [self windowNumber], blurFilter, kCGWindowFilterUnderlay);
    }
    blurRadius_ = radius;
#endif
}

- (void)disableBlur
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
    //only works in Leopard (or hopefully later)
    if (!OSX_LEOPARDORLATER) return;

    CGSConnectionID con = CGSMainConnectionID();
    if (!con) {
        return;
    }

    CGSSetWindowBackgroundBlurRadiusFunction* function = GetCGSSetWindowBackgroundBlurRadiusFunction();
    if (function) {
        function(con, [self windowNumber], 0);
    } else if (blurFilter) {
        CGSRemoveWindowFilter(con, (CGSWindowID)[self windowNumber], blurFilter);
        CGSReleaseCIFilter(CGSMainConnectionID(), blurFilter);
        blurFilter = 0;
    }
#endif
}

- (void)toggleFullScreen:(id)sender
{
    // This is a way of calling [super toggleFullScreen:] that doesn't give a warning if
    // the method doesn't exist (it's new in 10.7) but we build against 10.5 sdk.
    IMP functionPointer = [NSWindow instanceMethodForSelector:_cmd];
    isTogglingLionFullScreen_ = true;
    functionPointer(self, _cmd, sender);
    isTogglingLionFullScreen_ = false;
}

- (BOOL)isTogglingLionFullScreen
{
    return isTogglingLionFullScreen_;
}

- (int)screenNumber
{
    return [[[[self screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
}

- (void)smartLayout
{
    NSEnumerator* iterator;

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
    CGSConnectionID con = CGSMainConnectionID();
    if (!con) return;
    CGSWorkspaceID currentSpace = -1;
    CGSGetWorkspace(con, &currentSpace);
#endif

    int currentScreen = [self screenNumber];
    NSRect screenRect = [[self screen] visibleFrame];

    // Get a list of relevant windows, same screen & workspace
    NSMutableArray* windows = [[NSMutableArray alloc] init];
    iterator = [[[iTermController sharedInstance] terminals] objectEnumerator];
    PseudoTerminal* term;
    while ((term = [iterator nextObject])) {
        PTYWindow* otherWindow = (PTYWindow*)[term window];
        if(otherWindow == self) continue;

        int otherScreen = [otherWindow screenNumber];
        if(otherScreen != currentScreen) continue;

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
        CGSWorkspaceID otherSpace = -1;
        CGSGetWindowWorkspace(con, [otherWindow windowNumber], &otherSpace);
        if(otherSpace != currentSpace) continue;
#endif

        [windows addObject:otherWindow];
    }


    // Find the spot on screen with the lowest window intersection
    float bestIntersect = INFINITY;
    NSRect bestFrame = [self frame];

    NSRect placementRect = NSMakeRect(
        screenRect.origin.x,
        screenRect.origin.y,
        screenRect.size.width-[self frame].size.width,
        screenRect.size.height-[self frame].size.height
    );

    for(int x = 0; x < placementRect.size.width/2; x += 50) {
        for(int y = 0; y < placementRect.size.height/2; y += 50) {
            NSRect testRects[4] = {[self frame]};

            // Top Left
            testRects[0].origin.x = placementRect.origin.x + x;
            testRects[0].origin.y = placementRect.origin.y + placementRect.size.height - y;

            // Top Right
            testRects[1] = testRects[0];
            testRects[1].origin.x = placementRect.origin.x + placementRect.size.width - x;

            // Bottom Left
            testRects[2] = testRects[0];
            testRects[2].origin.y = placementRect.origin.y + y;

            // Bottom Right
            testRects[3] = testRects[1];
            testRects[3].origin.y = placementRect.origin.y + y;

            for(int i = 0; i < sizeof(testRects)/sizeof(NSRect); i++) {
                iterator = [windows objectEnumerator];
                PTYWindow* other;
                float badness = 0.0f;
                while ((other = [iterator nextObject])) {
                    NSRect otherFrame = [other frame];
                    NSRect intersection = NSIntersectionRect(testRects[i], otherFrame);
                    badness += intersection.size.width * intersection.size.height;
                }

#if DEBUG_WINDOW_LAYOUT
                static const char const * names[] = {"TL", "TR", "BL", "BR"};
                NSLog(@"%s: testRect:%@, bad:%.2f", names[i], NSStringFromRect(testRects[i]), badness);
#endif

                if(badness < bestIntersect) {
                    bestIntersect = badness;
                    bestFrame = testRects[i];
                }

                // Shortcut if we've found an empty spot
                if(bestIntersect == 0) {
                    goto end;
                }
            }
        }
    }

end:
    [windows release];
    [super setFrameOrigin:bestFrame.origin];
}

- (void)setLayoutDone
{
    layoutDone = YES;
}

- (void)makeKeyAndOrderFront:(id)sender
{
    if(!layoutDone) {
        layoutDone = YES;
        [[self delegate] windowWillShowInitial];
    }
    PtyLog(@"PTYWindow - calling makeKeyAndOrderFont, which triggers a window resize");
    PtyLog(@"The current window frame is %fx%f", [self frame].size.width, [self frame].size.height);
    [super makeKeyAndOrderFront:sender];
}

- (void)toggleToolbarShown:(id)sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[PTYWindow toggleToolbarShown]",
          __FILE__, __LINE__);
#endif
    id delegate = [self delegate];

    // Let our delegate know
    if([delegate conformsToProtocol: @protocol(PTYWindowDelegateProtocol)])
    [delegate windowWillToggleToolbarVisibility: self];

    [super toggleToolbarShown: sender];

    // Let our delegate know
    if([delegate conformsToProtocol: @protocol(PTYWindowDelegateProtocol)])
    [delegate windowDidToggleToolbarVisibility: self];

}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end
