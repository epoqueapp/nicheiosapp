//
//  WorldModel.m
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "WorldModel.h"

@implementation WorldModel


-(id)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err{
    self = [super init];
    if (self) {
        self.worldId = [dict objectForKey:@"worldId"];
        self.name = [dict objectForKey:@"name"];
        self.detail = [dict objectForKey:@"detail"];
        self.imageUrl = [dict objectForKey:@"imageUrl"];
        self.passcode = [dict objectForKey:@"passcode"];
        self.isDefault = [[dict objectForKey:@"isDefault"] boolValue];
        self.moderatorUserIds = [dict objectForKey:@"moderatorUserIds"];
        if ([self.moderatorUserIds isKindOfClass:[NSNull class]]) {
            self.moderatorUserIds = @[];
        }
        self.memberUserIds = [dict objectForKey:@"memberUserIds"];
        if ([self.memberUserIds isKindOfClass:[NSNull class]]) {
            self.memberUserIds = @[];
        }
        
        self.favoritedUserIds = [dict objectForKey:@"favoritedUserIds"];
        if ([self.favoritedUserIds isKindOfClass:[NSNull class]] || self.favoritedUserIds == nil) {
            self.favoritedUserIds = @[];
        }
    }
    return self;
}

-(id)initWithSnapshot:(FDataSnapshot *)snapshot{
    self = [super init];
    if (self) {
        NSString *key = snapshot.key;
        self.worldId = key;
        if (snapshot.value == [NSNull null]) {
            return self;
        }
        
        NSDictionary *dict = snapshot.value;
        self.name = [dict objectForKey:@"name"];
        self.detail = [dict objectForKey:@"detail"];
        self.imageUrl = [dict objectForKey:@"imageUrl"];
        self.passcode = [dict objectForKey:@"passcode"];
        self.isDefault = [[dict objectForKey:@"isDefault"] boolValue];
        self.moderatorUserIds = [dict objectForKey:@"moderatorUserIds"];
        if ([self.moderatorUserIds isKindOfClass:[NSNull class]] || self.moderatorUserIds == nil) {
            self.moderatorUserIds = @[];
        }
        self.memberUserIds = [dict objectForKey:@"memberUserIds"];
        if ([self.memberUserIds isKindOfClass:[NSNull class]] || self.memberUserIds == nil) {
            self.memberUserIds = @[];
        }
        
        self.favoritedUserIds = [dict objectForKey:@"favoritedUserIds"];
        if ([self.favoritedUserIds isKindOfClass:[NSNull class]] || self.favoritedUserIds == nil) {
            self.favoritedUserIds = @[];
        }
    }
    return self;
}

-(id)initWithHit:(NSDictionary *)hit{
    self = [super init];
    if (self) {
        self.worldId = hit[@"_id"];
        NSDictionary *source = hit[@"_source"];
        self.name = source[@"name"];
        self.detail = source[@"detail"];
        self.imageUrl = source[@"imageUrl"];
        self.isDefault = [source[@"isDefault"] boolValue];
        self.passcode = source[@"passcode"];
        self.memberUserIds = source[@"memberUserIds"];
        if ([self.memberUserIds isKindOfClass:[NSNull class]] || self.memberUserIds == nil) {
            self.memberUserIds = @[];
        }
        
        self.moderatorUserIds = source[@"moderatorUserIds"];
        if ([self.moderatorUserIds isKindOfClass:[NSNull class]] || self.moderatorUserIds == nil) {
            self.moderatorUserIds = @[];
        }
        self.favoritedUserIds = source[@"favoritedUserIds"];
        if ([self.favoritedUserIds isKindOfClass:[NSNull class]] || self.favoritedUserIds == nil) {
            self.favoritedUserIds = @[];
        }
    }
    return self;
}

-(BOOL)belongsToWorld:(NSString *)userId{
    BOOL isMemberOrModerator = [self.memberUserIds containsObject:userId] || [self.moderatorUserIds containsObject:userId];
    return isMemberOrModerator;
}

-(BOOL)canEnterWorld:(NSString *)userId{
    if ([self hasPasscode]) {
        return [self belongsToWorld:userId];
    }else{
        return YES;
    }
}

-(BOOL)hasPasscode{
    return ![NSString isStringEmpty:self.passcode];
}


@end
