//
//  PrivateChatModel.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/12/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "PrivateMessageModel.h"

@implementation PrivateMessageModel

-(id)initWithSnapshot:(FDataSnapshot *)snapshot{
    self = [super init];
    if (self) {
        self.privateMessageId = snapshot.key;
        if (snapshot.value != [NSNull null]) {
            NSDictionary *dict = [snapshot value];
            self.messageText = [dict objectForKey:@"messageText"];
            self.messageImageUrl = [dict objectForKey:@"messageImageUrl"];
            self.timestamp = [NSDate dateFromJavascriptTimestamp:[dict objectForKey:@"timestamp"]];
            self.senderUserId = [dict objectForKey:@"senderUserId"];
            self.senderUserName = [dict objectForKey:@"senderUserName"];
            self.senderUserSpriteUrl = [dict objectForKey:@"senderUserSpriteUrl"];
        }
    }
    return self;
}

@end
