/* -*- mode:objc -*-
 **
 **  PreferencesModel.h
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

#define OPT_NORMAL 0
#define OPT_META   1
#define OPT_ESC    2

// Modifier tags
#define MOD_TAG_CONTROL       1
#define MOD_TAG_LEFT_OPTION   2
#define MOD_TAG_RIGHT_OPTION  3
#define MOD_TAG_ANY_COMMAND   4
#define MOD_TAG_OPTION        5  // refers to any option key
#define MOD_TAG_CMD_OPT       6  // both cmd and opt at the same time
#define MOD_TAG_LEFT_COMMAND  7
#define MOD_TAG_RIGHT_COMMAND 8

typedef enum { CURSOR_UNDERLINE, CURSOR_VERTICAL, CURSOR_BOX } ITermCursorType;



#import <Cocoa/Cocoa.h>


@interface PreferencesModel : NSObject {

}

@end
