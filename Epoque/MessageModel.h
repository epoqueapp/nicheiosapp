//
//  MessageModel.h
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <JSONModel/JSONModel.h>
#import "UserModel.h"

@interface MessageModel : JSONModel

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userImageUrl;
@property (nonatomic, copy) NSString *userSpriteUrl;
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, copy) NSString *messageImageUrl;
@property (nonatomic, strong) NSArray *likedUserIds;
@property (nonatomic, assign) CLLocationCoordinate2D geo;
@property (nonatomic, copy) NSDate *timestamp;
@property (nonatomic, assign) BOOL isObscuring;

-(id)initWithSnapshot:(FDataSnapshot *)dataSnapShot;

@end
