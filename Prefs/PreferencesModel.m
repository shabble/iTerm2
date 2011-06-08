/* -*- mode:objc -*-
 **
 **  PreferencesModel.m
 **
 **  Copyright (c) 2011
 **
 **  Author: Tom Feist
 **
 **  Project: iTerm2
 **
 **  Description: Implements the model for holding preference (config) data.
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

#import "PreferencesModel.h"


@implementation PreferencesModel

@synthesize  bookmarkDataSource;
@synthesize  oneBookmarkMode;
@synthesize  defaultWindowStyle;
@synthesize  oneBookmarkOnly; 
@synthesize  defaultTabViewType;
@synthesize  defaultCopySelection;
@synthesize  defaultPasteFromClipboard;
@synthesize  defaultHideTab;
@synthesize  defaultPromptOnClose;
@synthesize  defaultPromptOnQuit;
@synthesize  defaultOnlyWhenMoreTabs;
@synthesize  defaultFocusFollowsMouse;
@synthesize  defaultWordChars;
@synthesize  defaultHotkeyTogglesWindow;
@synthesize  defaultHotKeyBookmarkGuid;
@synthesize  defaultEnableBonjour;
@synthesize  defaultCmdSelection;
@synthesize  defaultPassOnControlLeftClick;
@synthesize  defaultMaxVertically;
@synthesize  defaultClosingHotkeySwitchesSpaces;
@synthesize  defaultUseCompactLabel;
@synthesize  defaultHighlightTabLabels;
@synthesize  defaultAdvancedFontRendering;
@synthesize  defaultStrokeThickness;
@synthesize  defaultOpenBookmark;
@synthesize  defaultQuitWhenAllWindowsClosed;
@synthesize  defaultCheckUpdate;
@synthesize  defaultColorInvertedCursor;
@synthesize  defaultDimInactiveSplitPanes;
@synthesize  defaultShowWindowBorder;
@synthesize  defaultHideScrollbar;
@synthesize  defaultSmartPlacement;
@synthesize  defaultFsTabDelay;
@synthesize  defaultWindowNumber;
@synthesize  defaultJobName;
@synthesize  defaultShowBookmarkName;
@synthesize  defaultInstantReplay;
@synthesize  defaultIrMemory;
@synthesize  defaultHotkey;
@synthesize  defaultHotkeyChar;
@synthesize  defaultHotkeyCode;
@synthesize  defaultHotkeyModifiers;
@synthesize  defaultSavePasteHistory;
@synthesize  defaultOpenArrangementAtStartup;
@synthesize  defaultCheckTestRelease;
@synthesize  prefs;
@synthesize  globalToolbarId;
@synthesize  appearanceToolbarId;
@synthesize  keyboardToolbarId;
@synthesize  bookmarksToolbarId;
@synthesize  urlHandlersByGuid;
@synthesize  backgroundImageFilename;
@synthesize  normalFont;
@synthesize  nonAsciiFont;
@synthesize  changingNAFont; 
@synthesize  keyString;  
@synthesize  newMapping;  
@synthesize  modifyMappingOriginator;  
@synthesize  defaultControl;
@synthesize  defaultLeftOption;
@synthesize  defaultRightOption;
@synthesize  defaultLeftCommand;
@synthesize  defaultRightCommand;
@synthesize  defaultSwitchTabModifier;
@synthesize  defaultSwitchWindowModifier;

@synthesize preferences;

@end
