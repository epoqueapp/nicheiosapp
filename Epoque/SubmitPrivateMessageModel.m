//
//  SubmitPrivateMessageModel.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "SubmitPrivateMessageModel.h"

@implementation SubmitPrivateMessageModel

-(id)init{
    self = [super init];
    if (self) {
        self.myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
        self.myUserName = [NSUserDefaults standardUserDefaults].userModel.name;
        self.myUserSpriteUrl = [NSUserDefaults standardUserDefaults].userModel.spriteUrl;
        self.timestamp = [NSDate date];
    }
    return self;
}

@end
