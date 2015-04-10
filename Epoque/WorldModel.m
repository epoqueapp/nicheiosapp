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
        self.tags = [dict objectForKey:@"tags"];
        self.imageUrl = [dict objectForKey:@"imageUrl"];
        self.isPrivate = [[dict objectForKey:@"isPrivate"] boolValue];
        self.isDefault = [[dict objectForKey:@"isDefault"] boolValue];
        self.moderatorUserIds = [dict objectForKey:@"moderatorUserIds"];
        self.memberUserIds = [dict objectForKey:@"memberUserIds"];
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
        self.tags = [dict objectForKey:@"tags"];
        self.imageUrl = [dict objectForKey:@"imageUrl"];
        self.isPrivate = [[dict objectForKey:@"isPrivate"] boolValue];
        self.isDefault = [[dict objectForKey:@"isDefault"] boolValue];
        self.moderatorUserIds = [dict objectForKey:@"moderatorUserIds"];
        self.memberUserIds = [dict objectForKey:@"memberUserIds"];
        
    }
    return self;
}

-(BOOL)belongsToWorld:(NSString *)userId{
    return [self.memberUserIds containsObject:userId] || [self.moderatorUserIds containsObject:userId];
}

@end
