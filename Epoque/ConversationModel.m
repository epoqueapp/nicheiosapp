//
//  ConversationModel.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/1/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "ConversationModel.h"

@implementation ConversationModel

-(id)initWithSnapshot:(FDataSnapshot *)snapshot{
    self = [super init];
    if (self) {
        self.regardingUserId = snapshot.key;
        if (snapshot.value != [NSNull null]) {
            NSDictionary *dict = snapshot.value;
            self.regardUserName = [dict objectForKey:@"regardingUserName"];
            self.regardingUserSpriteUrl = [dict objectForKey:@"regardingUserSpriteUrl"];
            self.messageImageUrl = [dict objectForKey:@"messageImageUrl"];
            self.messageText = [dict objectForKey:@"messageText"];
            self.timestamp = [NSDate dateFromJavascriptTimestamp: [dict objectForKey:@"timestamp"]];
        }
    }
    return self;
}

-(id)initWithSubvalue:(NSString *)key dictionary:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        self.regardingUserId = key;
        self.regardUserName = [dict objectForKey:@"regardingUserName"];
        self.regardingUserSpriteUrl = [dict objectForKey:@"regardingUserSpriteUrl"];
        self.messageImageUrl = [dict objectForKey:@"messageImageUrl"];
        self.messageText = [dict objectForKey:@"messageText"];
        self.timestamp = [NSDate dateFromJavascriptTimestamp: [dict objectForKey:@"timestamp"]];
    }
    return self;
}

@end
