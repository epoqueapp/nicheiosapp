//
//  EPSpriteService.m
//  Niche
//
//  Created by Maximilian Alexander on 3/18/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "EPSpriteService.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>

@implementation EPSpriteService

+(id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc]init];
    });
    return _sharedObject;
}

-(RACSignal *)getSprites{
    return [[[AFHTTPRequestOperationManager alloc]init] rac_GET:@"https://prod.epoquecore.com/sprites" parameters:@{}];
}

@end
