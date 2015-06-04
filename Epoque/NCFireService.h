//
//  NCFireService.h
//  Niche
//
//  Created by Maximilian Alexander on 3/18/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <CoreLocation/CoreLocation.h>
#import "MessageModel.h"
#import "WorldModel.h"
#import "SubmitPrivateMessageModel.h"
@interface NCFireService : NSObject

+(id)sharedInstance;

-(RACSignal *)createUserWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name spriteUrl:(NSString *)spriteUrl;
-(RACSignal *)loginWithEmail:(NSString *)email password:(NSString *)password;
-(RACSignal *)logout;

-(RACSignal *)createWorld:(WorldModel *)worldModel;
-(RACSignal *)updateWorld:(WorldModel *)worldModel;
-(RACSignal *)deleteWorld:(NSString *)worldId;

-(RACSignal *)submitPrivateMessage:(SubmitPrivateMessageModel *)submitPrivateMessageModel;

-(RACSignal *)registerUserId:(NSString *)userId deviceToken:(NSString *)deviceToken environment:(NSString *)environment;

-(FAuthData *)authData;
-(Firebase *)worldsRef;
-(Firebase *)worldMessagesRef:(NSString *)worldId;
-(Firebase *)worldShoutsRef:(NSString *)worldShouts;
-(Firebase *)worldPushBusRef:(NSString *)worldId;
-(Firebase *)worldPushSettings:(NSString *)worldId userId:(NSString *)userId;
-(Firebase *)rootRef;
-(Firebase *)usersRef;
@end
