//
//  PrivateChatModel.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/12/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "JSONModel.h"

@interface PrivateMessageModel : JSONModel

@property (nonatomic, strong) NSString *privateMessageId;
@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) NSString *messageImageUrl;
@property (nonatomic, strong) NSString *senderUserId;
@property (nonatomic, strong) NSString *senderUserName;
@property (nonatomic, strong) NSString *senderUserSpriteUrl;
@property (nonatomic, strong) NSDate *timestamp;

-(id)initWithSnapshot:(FDataSnapshot *)snapshot;

@end
