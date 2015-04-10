//
//  EPSpriteService.h
//  Niche
//
//  Created by Maximilian Alexander on 3/18/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPSpriteService : NSObject

+(id)sharedInstance;

-(RACSignal *)getSprites;

@end
