//
//  NCWorldService.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/3/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCWorldService : NSObject

-(RACSignal *)searchWorlds:(NSString *)searchTerm;
-(RACSignal *)getFavoritedWorlds;
-(RACSignal *)getDefaultWorlds;

+(id)sharedInstance;

@end
