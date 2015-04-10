//
//  NCWorldService.h
//  Niche
//
//  Created by Maximilian Alexander on 3/29/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorldModel.h"
@interface NCWorldService : NSObject

+(id)sharedInstance;

-(RACSignal *)createWorld:(WorldModel *)worldModel;
-(RACSignal *)updateWorld:(WorldModel *)worldModel;
-(RACSignal *)deleteWorldWithId:(NSString *)worldId;
-(RACSignal *)getWorldById:(NSString *)worldId;

-(RACSignal *)joinWorldById:(NSString *)worldId;
-(RACSignal *)unjoinWorldById:(NSString *)worldId;

-(RACSignal *)searchWorlds:(NSString *)searchTerm;
-(RACSignal *)getMyWorlds;

@end
