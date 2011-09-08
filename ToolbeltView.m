//
//  ToolbeltView.m
//  iTerm
//
//  Created by George Nachman on 9/5/11.
//  Copyright 2011 Georgetech. All rights reserved.
//

#import "ToolbeltView.h"
#import "ToolProfiles.h"
#import "ToolPasteHistory.h"
#import "ToolWrapper.h"
#import "ToolJobs.h"

@interface ToolbeltView (Private)

+ (NSDictionary *)toolsDictionary;
- (void)addTool:(NSView<ToolbeltTool> *)theTool toWrapper:(ToolWrapper *)wrapper;
- (void)addToolWithName:(NSString *)theName;
- (void)setHaveOnlyOneTool:(BOOL)value;

@end

@implementation ToolbeltView

static NSMutableDictionary *gRegisteredTools;
static NSString *kToolbeltPrefKey = @"ToolbeltTools";

+ (void)initialize
{
    gRegisteredTools = [[NSMutableDictionary alloc] init];
    [ToolbeltView registerToolWithName:@"Paste History" withClass:[ToolPasteHistory class]];
    [ToolbeltView registerToolWithName:@"Profiles" withClass:[ToolProfiles class]];
    [ToolbeltView registerToolWithName:@"Jobs" withClass:[ToolJobs class]];
}

+ (NSArray *)defaultTools
{
    return [NSArray arrayWithObjects:@"Profiles", nil];
}

+ (NSArray *)allTools
{
    return [gRegisteredTools allKeys];
}

+ (NSArray *)configuredTools
{
    NSArray *tools = [[NSUserDefaults standardUserDefaults] objectForKey:kToolbeltPrefKey];
    if (!tools) {
        return [ToolbeltView defaultTools];
    }
    return tools;
}

- (id)initWithFrame:(NSRect)frame term:(PseudoTerminal *)term
{
    self = [super initWithFrame:frame];
    if (self) {
        term_ = term;

        NSArray *items = [ToolbeltView configuredTools];
        if (!items) {
            items = [ToolbeltView defaultTools];
            [[NSUserDefaults standardUserDefaults] setObject:items forKey:kToolbeltPrefKey];
        }

        splitter_ = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        [splitter_ setVertical:NO];
        [splitter_ setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [splitter_ setDividerStyle:NSSplitViewDividerStyleThin];
        [splitter_ setDelegate:self];
        [self addSubview:splitter_];
        tools_ = [[NSMutableDictionary alloc] init];

        for (NSString *theName in items) {
            if ([ToolbeltView shouldShowTool:theName]) {
                [self addToolWithName:theName];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [splitter_ release];
    [tools_ release];
    [super dealloc];
}

- (void)shutdown
{
    while ([tools_ count]) {
        NSString *theName = [[tools_ allKeys] objectAtIndex:0];

        ToolWrapper *wrapper = [tools_ objectForKey:theName];
        [tools_ removeObjectForKey:theName];
        [wrapper unbind];
        [wrapper removeFromSuperview];
    }
}

+ (void)registerToolWithName:(NSString *)name withClass:(Class)c
{
    [gRegisteredTools setObject:c forKey:name];
}

+ (NSDictionary *)toolsDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *toolName in gRegisteredTools) {
        [dict setObject:[[[[gRegisteredTools objectForKey:toolName] alloc] init] autorelease]
                 forKey:toolName];
    }
    return dict;
}

+ (BOOL)shouldShowTool:(NSString *)name
{
    return [[ToolbeltView configuredTools] indexOfObject:name] != NSNotFound;
}

+ (void)toggleShouldShowTool:(NSString *)theName
{
    NSMutableArray *tools = [[[ToolbeltView configuredTools] mutableCopy] autorelease];
    if (!tools) {
        tools = [[[ToolbeltView defaultTools] mutableCopy] autorelease];
    }
    if ([tools indexOfObject:theName] == NSNotFound) {
        [tools addObject:theName];
    } else {
        [tools removeObject:theName];
    }
    [[NSUserDefaults standardUserDefaults] setObject:tools forKey:kToolbeltPrefKey];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"iTermToolToggled"
                                                        object:theName
                                                      userInfo:nil];
}

+ (int)numberOfVisibleTools
{
    NSArray *tools = [ToolbeltView configuredTools];
    if (!tools) {
        tools = [ToolbeltView defaultTools];
    }
    return [tools count];
}

- (void)toggleToolWithName:(NSString *)theName
{
    ToolWrapper *wrapper = [tools_ objectForKey:theName];
    if (wrapper) {
        [tools_ removeObjectForKey:theName];
        [wrapper unbind];
        [wrapper removeFromSuperview];
    } else {
        [self addToolWithName:theName];
    }
    [self setHaveOnlyOneTool:[self haveOnlyOneTool]];
}

- (BOOL)showingToolWithName:(NSString *)theName
{
    return [tools_ objectForKey:theName] != nil;
}

+ (void)populateMenu:(NSMenu *)menu
{
    NSArray *names = [[ToolbeltView allTools] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *theName in names) {
        NSMenuItem *i = [[[NSMenuItem alloc] initWithTitle:theName action:@selector(toggleToolbeltTool:) keyEquivalent:@""] autorelease];
        [i setState:[ToolbeltView shouldShowTool:theName] ? NSOnState : NSOffState];
        [menu addItem:i];
    }
}

- (void)addTool:(NSView<ToolbeltTool> *)theTool toWrapper:(ToolWrapper *)wrapper
{
    [splitter_ addSubview:wrapper];
    [wrapper release];
    [wrapper.container addSubview:theTool];

    [wrapper setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [theTool setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [splitter_ adjustSubviews];
    [wrapper bindCloseButton];
    [tools_ setObject:wrapper forKey:[[wrapper.name copy] autorelease]];
}

- (void)addToolWithName:(NSString *)toolName
{
    ToolWrapper *wrapper = [[ToolWrapper alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    wrapper.name = toolName;
    wrapper.term = term_;
    Class c = [gRegisteredTools objectForKey:toolName];
    [self addTool:[[[c alloc] initWithFrame:NSMakeRect(0, 0, wrapper.container.frame.size.width, wrapper.container.frame.size.height)] autorelease]
        toWrapper:wrapper];
    [self setHaveOnlyOneTool:[self haveOnlyOneTool]];
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)setHaveOnlyOneTool:(BOOL)value
{
    // For KVO
}

- (BOOL)haveOnlyOneTool
{
    return [[splitter_ subviews] count] == 1;
}

@end
