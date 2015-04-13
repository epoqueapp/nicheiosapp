//
//  ConversationModel.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/1/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "JSONModel.h"

@interface ConversationModel : JSONModel

@property (nonatomic, copy) NSString *regardingUserId;
@property (nonatomic, copy) NSString *regardUserName;
@property (nonatomic, copy) NSString *regardingUserSpriteUrl;
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, copy) NSString *messageImageUrl;
@property (nonatomic, copy) NSDate *timestamp;

-(id)initWithSnapshot:(FDataSnapshot *)snapshot;
-(id)initWithSubvalue:(NSString *)key dictionary:(NSDictionary *)dict;

@end
