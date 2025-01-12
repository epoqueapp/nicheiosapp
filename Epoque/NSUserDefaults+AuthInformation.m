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
    NSDictionary *userDictionary = [userModel toDictionary];
    [self setObject:userDictionary forKey:kNCUserModel];
    [[Amplitude instance] setUserId:userModel.userId];
    [[Amplitude instance] setUserProperties:userDictionary];
}

-(UserModel *)userModel{
    NSDictionary *retrievedUserModel = [self objectForKey:kNCUserModel];
    if (retrievedUserModel == nil) {
        return nil;
    }
    UserModel *model = [[UserModel alloc]initWithDictionary:retrievedUserModel error:nil];
    return model;
}

-(void)setWorldMapEnabled:(BOOL)isWorldMapEnabled{
    [self setObject:@(isWorldMapEnabled) forKey:kNCWorldMapEnabled];
}

-(BOOL)worldMapEnabled{
    return [[self objectForKey:kNCWorldMapEnabled] boolValue];
}

-(void)clearAuthInformation{
    [self setObject:nil forKey:kNCWelcomeSpriteUrl];
    [self setObject:nil forKey:kNCUserModel];
    [self setObject:nil forKey:kNCDeviceToken];
    [self setObject:nil forKey:kNCObscurity];
    [self setObject:nil forKey:kNCCurrentWorldId];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

-(void)setDeviceToken:(NSString *)deviceToken{
    [self setObject:deviceToken forKey:kNCDeviceToken];
}

-(NSString *)deviceToken{
    return [self objectForKey:kNCDeviceToken];
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

-(BOOL)isObscuring{
    return [[self objectForKey:kNCIsObscuring] boolValue];
}

-(void)setIsObscuring:(BOOL)isObscuring{
    [self setObject:@(isObscuring) forKey:kNCIsObscuring];
}

-(BOOL)isFavoriteMode{
    return [[self objectForKey:kNCIsFavoriteMode] boolValue];
}

-(void)setIsFavoriteMode:(BOOL)isFavoriteMode{
    [self setObject:@(isFavoriteMode) forKey:kNCIsFavoriteMode];
}

-(void)setQuotes:(NSArray *)quoteObjects{
    [self setObject:quoteObjects forKey:kNCQuotes];
}

-(NSArray *)quotes{
    NSArray *retrievedQuotes = [self objectForKey:kNCQuotes];
    if (retrievedQuotes == nil) {
        return @[];
    }
    return retrievedQuotes;
}

-(NSDictionary *)randomQuote{
    NSArray *fetchedQuotes = [self quotes];
    if ([fetchedQuotes count] == 0) {
        return @{
                 @"content": @"Don't be shy.",
                 @"author": @"Epoque Team",
                 @"likeCount": @43,
                 @"timestamp": [NSDate javascriptTimestampNow]
                 };
    }
    return [fetchedQuotes randomObject];
}

-(void)setCurrentWorldId:(NSString *)worldId{
    [self setObject:worldId forKey:kNCCurrentWorldId];
}

-(NSString *)currentWorldId {
    NSString *wId = [self objectForKey:kNCCurrentWorldId];
    if(wId == nil){
        return @"open-world";
    }else{
        return wId;
    }
}


@end
