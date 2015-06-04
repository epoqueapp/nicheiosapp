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
#define kNCWorldMapEnabled @"kNCWorldMapEnabled"
#define kNCDeviceToken @"kNCDeviceToken"
#define kNCObscurity @"kNCObscurity"
#define kNCBlockedUserIds @"kNCBlockedUserIds"
#define kNCIsObscuring @"kNCIsObscuring"
#define kNCIsFavoriteMode @"kNCIsFavoriteMode"
#define kNCIsLocationUpdateOn @"kNCIsLocationUpdateOn"
#define kNCQuotes @"kNCQuotes"
#define kNCCurrentWorldId @"kNCCurrentWorldId"
#define kNCRemoteDeviceToken @"kNCRemoteDeviceToken"

@interface NSUserDefaults (AuthInformation)

-(void)setWelcomeSpriteUrl:(NSString *)welcomeSpriteUrl;
-(NSString *)welcomeSpriteUrl;

-(void)setUserModel:(UserModel *)userModel;
-(UserModel *)userModel;

-(void)setWorldMapEnabled:(BOOL)isWorldMapEnabled;
-(BOOL)worldMapEnabled;

-(void)clearAuthInformation;

-(void)setDeviceToken:(NSString *)deviceToken;
-(NSString *)deviceToken;

-(void)blockUserWithId:(NSString *)userId;
-(void)unblockUserId:(NSString *)userId;
-(NSArray *)blockedUserIds;
-(BOOL)isUserBlocked:(NSString *)userId;

-(BOOL)isObscuring;
-(void)setIsObscuring:(BOOL)isObscuring;

-(BOOL)isFavoriteMode;
-(void)setIsFavoriteMode:(BOOL)isFavoriteMode;

-(void)setQuotes:(NSArray *)quoteObjects;
-(NSArray *)quotes;
-(NSDictionary *)randomQuote;

-(void)setCurrentWorldId:(NSString *)worldId;
-(NSString *)currentWorldId;

-(void)setRemoteDeviceToken:(NSString *)deviceToken;
-(NSString *)remoteDeviceToken;

@end
