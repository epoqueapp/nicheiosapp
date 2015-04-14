//
//  NCUserService.h
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorldModel.h"


@interface NCUserService : NSObject

+(id)sharedInstance;

-(RACSignal *)loginWithEmail:(NSString *)email password:(NSString *)password;
-(RACSignal *)loginWithFacebookAccessToken:(NSString *)facebookAccessToken spriteUrl:(NSString *)spriteUrl;
-(RACSignal *)signupWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name about:(NSString *)about spriteUrl:(NSString *)spriteUrl imageUrl:(NSString *)imageUrl;

-(RACSignal *)updateMe:(UserModel *)userModel;
-(RACSignal *)sendFeedbackWithContent:(NSString *)content;

-(RACSignal *)getMembersByWorldId:(NSString *)worldId;

-(RACSignal *)getInviteAbleUsersForWorldId:(NSString *)worldId searchTerm:(NSString *)searchTerm;

-(RACSignal *)removeUserFromWorld:(NSString *)worldId userId:(NSString *)userId;
-(RACSignal *)addUserToWorldId:(NSString *)worldId userId:(NSString *)userId isModerator:(BOOL)isModerator;

-(RACSignal *)sendReport:(NSString *)userId content:(NSString *)content;
@end
