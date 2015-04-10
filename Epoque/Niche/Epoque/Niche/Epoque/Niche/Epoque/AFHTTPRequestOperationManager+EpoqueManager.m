//
//  AFHTTPRequestOperationManager+EpoqueManager.m
//  Niche
//
//  Created by Maximilian Alexander on 3/29/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "AFHTTPRequestOperationManager+EpoqueManager.h"

@implementation AFHTTPRequestOperationManager (EpoqueManager)

+(AFHTTPRequestOperationManager *)epoqueManager{
    NSString *accessToken = [NSUserDefaults standardUserDefaults].accessToken;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    if (accessToken) {
        [manager.requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    }
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return manager;
}

@end
