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
@property (nonatomic, copy) NSString *summaryText;
@property (nonatomic, copy) NSDate *timestamp;

@end
