//
//  SubmitPrivateMessageModel.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "JSONModel.h"

@interface SubmitPrivateMessageModel : JSONModel

@property (nonatomic, copy) NSString *toUserId;
@property (nonatomic, copy) NSString *toUserName;
@property (nonatomic, copy) NSString *myUserName;
@property (nonatomic, copy) NSString *myUserSpriteUrl;
@property (nonatomic, copy) NSString *myUserId;
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, copy) NSString *messageImageUrl;
@property (nonatomic, copy) NSDate *timestamp;

@end
