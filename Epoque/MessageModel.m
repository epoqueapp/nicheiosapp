//
//  MessageModel.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

-(id)initWithSnapshot:(FDataSnapshot *)dataSnapShot{
    self = [super init];
    if (self) {
        self.messageId = dataSnapShot.key;
        self.messageText = [[dataSnapShot.value objectForKey:@"messageText"] copy];
        self.messageImageUrl = [[dataSnapShot.value objectForKey:@"messageImageUrl"] copy];
        self.userSpriteUrl = [[dataSnapShot.value objectForKey:@"userSpriteUrl"] copy];
        self.userName = [[dataSnapShot.value objectForKey:@"userName"] copy];
        self.userId = [[dataSnapShot.value objectForKey:@"userId"]copy];
        self.userImageUrl = [[dataSnapShot.value objectForKey:@"userImageUrl"]copy];
        self.timestamp = [NSDate dateFromJavascriptTimestamp:[[dataSnapShot.value objectForKey:@"timestamp"]copy]];
        self.isObscuring = [[dataSnapShot.value objectForKey:@"isObscuring"] boolValue];
        float latitude = [[[dataSnapShot.value objectForKey:@"geo"] objectAtIndex:1] floatValue];
        float longitude = [[[dataSnapShot.value objectForKey:@"geo"] objectAtIndex:1] floatValue];
        self.geo = CLLocationCoordinate2DMake(latitude, longitude);
        self.likedUserIds = [dataSnapShot.value objectForKey:@"likedUserIds"];
        if (self.likedUserIds == nil || [self.likedUserIds isEqual: [NSNull null]]) {
            self.likedUserIds = @[];
        }
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err{
    self = [super init];
    if (self) {
        self.messageText = [[dict objectForKey:@"messageText"] copy];
        self.messageImageUrl = [[dict objectForKey:@"messageImageUrl"] copy];
        self.userSpriteUrl = [[dict objectForKey:@"userSpriteUrl"] copy];
        self.userName = [[dict objectForKey:@"userName"] copy];
        self.userId = [[dict objectForKey:@"userId"]copy];
        self.userImageUrl = [[dict objectForKey:@"userImageUrl"]copy];
        self.timestamp = [NSDate dateFromJavascriptTimestamp:[[dict objectForKey:@"timestamp"]copy]];
        self.isObscuring = [[dict objectForKey:@"isObscuring"] boolValue];
        float latitude = [[[dict objectForKey:@"geo"] objectAtIndex:1] floatValue];
        float longitude = [[[dict objectForKey:@"geo"] objectAtIndex:1] floatValue];
        self.geo = CLLocationCoordinate2DMake(latitude, longitude);
        self.likedUserIds = [dict objectForKey:@"likedUserIds"];
        if (self.likedUserIds == nil || [self.likedUserIds isEqual: [NSNull null]]) {
            self.likedUserIds = @[];
        }
    }
    return self;
}

@end
