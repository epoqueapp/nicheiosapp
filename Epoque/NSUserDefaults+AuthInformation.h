//
//  NSUserDefaults+AuthInformation.h
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#define kNCWelcomeSpriteUrl @"kNCWelcomeSpriteUrl"
#define kNCUserModel @"kNCUserModel"
#define kNCAccessToken @"kNCAccessToken"
#define kNCWorldMapEnabled @"kNCWorldMapEnabled"
#define kNCDeviceToken @"kNCDeviceToken"
#define kNCObscurity @"kNCObscurity"
#define kNCBlockedUserIds @"kNCBlockedUserIds"

@interface NSUserDefaults (AuthInformation)

-(void)setWelcomeSpriteUrl:(NSString *)welcomeSpriteUrl;
-(NSString *)welcomeSpriteUrl;

-(void)setUserModel:(UserModel *)userModel;
-(UserModel *)userModel;

-(void)setAccessToken:(NSString *)accessToken;
-(NSString *)accessToken;

-(void)setWorldMapEnabled:(BOOL)isWorldMapEnabled;
-(BOOL)worldMapEnabled;

-(void)clearAuthInformation;

-(void)setDeviceToken:(NSString *)deviceToken;
-(NSString *)deviceToken;

-(void)setObscurity:(float)obscurity;
-(float)obscurity;

-(void)blockUserWithId:(NSString *)userId;
-(void)unblockUserId:(NSString *)userId;
-(NSArray *)blockedUserIds;
-(BOOL)isUserBlocked:(NSString *)userId;
@end
