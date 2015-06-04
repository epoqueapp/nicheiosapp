//
//  SendMessageModel.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/22/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "SendMessageModel.h"

@implementation SendMessageModel

-(id)init{
    self = [super init];
    if (self) {
        self.messageImageUrl = @"";
        self.messageText = @"";
        self.messageVideoUrl = @"";
        self.location = [[CLLocation alloc]initWithLatitude:0 longitude:0];
    }
    return self;
}

-(NSDictionary *)toDictionary{
    
    UserModel *userModel  = [NSUserDefaults standardUserDefaults].userModel;
    NSDictionary *json = @{
             @"messageText": self.messageText,
             @"messageImageUrl": self.messageImageUrl,
             @"messageVideoUrl": self.messageVideoUrl,
             @"geo": [self.location toGeoJson],
             @"userId": userModel.userId,
             @"userName": userModel.name,
             @"userSpriteUrl": userModel.spriteUrl,
             @"timestamp": kFirebaseServerValueTimestamp,
             @"worldId": self.worldId
             };
    
    return json;
}

@end
