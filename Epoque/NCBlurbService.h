//
//  NCBlurbService.h
//  Epoque
//
//  Created by Maximilian Alexander on 6/8/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlurbModel.h"  
@interface NCBlurbService : NSObject

+ (id)sharedInstance;

-(RACSignal *)observeSingleBlurbByWorldId:(NSString *)worldId blurbId:(NSString *)blurbId;

@end
