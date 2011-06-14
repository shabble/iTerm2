/*
 **  ProfilesManager.h (was ITAddressBookMgr.h)
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **
 **  Project: iTerm2
 **
 **  Description: keeps track of the address book data.
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
// Notes:
// Empty or bogus font? Use [NSFont userFixedPitchFontOfSize: 0.0]


#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Profiles/ProfileModel.h"
#import "Prefs/PreferenceKeys.h"

@interface ProfileManager : NSObject
{
    NSNetServiceBrowser *sshBonjourBrowser;
    NSNetServiceBrowser *ftpBonjourBrowser;
    NSNetServiceBrowser *telnetBonjourBrowser;
    NSMutableArray *bonjourServices;
}


@end

@interface ProfileManager (Private)

+ (id)sharedInstance;
+ (NSArray*)encodeColor:(NSColor*)origColor;
+ (NSColor*)decodeColor:(NSDictionary*)plist;
+ (void)setDefaultsInProfile:(NSMutableDictionary*)dict;

+ (NSFont*)fontWithDesc:(NSString *)fontDesc;
+ (NSString*)descFromFont:(NSFont*)font;

- (id)init;
- (void)dealloc;
- (void)locateBonjourServices;
- (void)stopLocatingBonjourServices;
- (void)copyProfileToProfile:(NSMutableDictionary *)dict;
- (void)recursiveMigrateProfiles:(NSDictionary*)node path:(NSArray*)array;
- (void)setProfiles:(NSArray*)newProfilesArray defaultGuid:(NSString*)guid;
- (ProfileModel*)model;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
- (void)netServiceDidResolveAddress:(NSNetService *)sender;
- (void)netService:(NSNetService *)aNetService didNotResolve:(NSDictionary *)errorDict;
- (void)netServiceWillResolve:(NSNetService *)aNetService;
- (void)netServiceDidStop:(NSNetService *)aNetService;
- (NSString*) getBonjourServiceType:(NSString*)aType;
+ (NSString*)loginShellCommandForProfile:(Profile*)profile;
+ (NSString*)profileCommand:(Profile*)profile isLoginSession:(BOOL*)isLoginSession;
+ (NSString*)profileWorkingDirectory:(Profile*)profile;

@end
