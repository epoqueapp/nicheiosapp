//
//  NSUserDefaults+AuthInformation.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NSUserDefaults+AuthInformation.h"

@implementation NSUserDefaults (AuthInformation)

-(void)setWelcomeSpriteUrl:(NSString *)welcomeSpriteUrl{
    [self setObject:welcomeSpriteUrl forKey:kNCWelcomeSpriteUrl];
}

-(NSString *)welcomeSpriteUrl{
    return [self objectForKey:kNCWelcomeSpriteUrl];
}

-(void)setUserModel:(UserModel *)userModel{
    if (userModel.imageUrl == nil) {
        userModel.imageUrl = @"";
    }
    NSDictionary *userDictionary = [userModel toDictionary];
    [self setObject:userDictionary forKey:kNCUserModel];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:userModel.userId];
    [mixpanel.people set:userDictionary];
}

-(UserModel *)userModel{
    NSDictionary *retrievedUserModel = [self objectForKey:kNCUserModel];
    if (retrievedUserModel == nil) {
        return nil;
    }
    UserModel *model = [[UserModel alloc]initWithDictionary:retrievedUserModel error:nil];
    return model;
}

-(void)setAccessToken:(NSString *)accessToken{
    [self setObject:accessToken forKey:kNCAccessToken];
}

-(NSString *)accessToken{
    return [self objectForKey:kNCAccessToken];
}

-(void)setWorldMapEnabled:(BOOL)isWorldMapEnabled{
    [self setObject:@(isWorldMapEnabled) forKey:kNCWorldMapEnabled];
}

-(BOOL)worldMapEnabled{
    return [[self objectForKey:kNCWorldMapEnabled] boolValue];
}

-(void)clearAuthInformation{
    [self setObject:nil forKey:kNCAccessToken];
    [self setObject:nil forKey:kNCWelcomeSpriteUrl];
    [self setObject:nil forKey:kNCUserModel];
    [self setObject:nil forKey:kNCDeviceToken];
    [self setObject:nil forKey:kNCObscurity];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

-(void)setDeviceToken:(NSString *)deviceToken{
    [self setObject:deviceToken forKey:kNCDeviceToken];
}

-(NSString *)deviceToken{
    return [self objectForKey:kNCDeviceToken];
}

-(void)setObscurity:(float)obscurity{
    return [self setObject:@(obscurity) forKey:kNCObscurity];
}

-(float)obscurity{
    return [[self objectForKey:kNCObscurity] floatValue];
}

-(void)blockUserWithId:(NSString *)userId{
    NSMutableArray *blockedUserIds = [self.blockedUserIds mutableCopy];
    if (![blockedUserIds containsObject:userId]) {
        [blockedUserIds addObject:userId];
    }
    [self setValue:blockedUserIds forKey:kNCBlockedUserIds];

}

-(void)unblockUserId:(NSString *)userId{
    NSMutableArray *blockedUserIds = [self.blockedUserIds mutableCopy];
    if ([blockedUserIds containsObject:userId]) {
        [blockedUserIds removeObject:userId];
    }
    [self setValue:blockedUserIds forKey:kNCBlockedUserIds];
}

-(NSArray *)blockedUserIds{
    NSArray *blockedUserIds = [self objectForKey: kNCBlockedUserIds];
    if (blockedUserIds == nil) {
        [self setObject:[NSArray array] forKey:kNCBlockedUserIds];
    }
    return [self objectForKey: kNCBlockedUserIds];
}

-(BOOL)isUserBlocked:(NSString *)userId{
    return [self.blockedUserIds containsObject:userId];
}

@end
