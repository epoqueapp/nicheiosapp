
//
//  NCBlurbService.m
//  Epoque
//
//  Created by Maximilian Alexander on 6/8/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCBlurbService.h"

@implementation NCBlurbService

+ (id)sharedInstance {
    static NCBlurbService *mySharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedInstance = [[self alloc] init];
    });
    return mySharedInstance;
}

-(RACSignal *)observeSingleBlurbByWorldId:(NSString *)worldId blurbId:(NSString *)blurbId{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        Firebase *ref = [[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"world-blurbs"] childByAppendingPath:worldId] childByAppendingPath:blurbId];
        FirebaseHandle handle = [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value == [NSNull null]) {
                
            }else{
                BlurbModel *blurbModel = [[BlurbModel alloc]initWithSnapshot:snapshot];
                [subscriber sendNext:blurbModel];
            }
        }];
        return [RACDisposable disposableWithBlock:^{
            [ref removeObserverWithHandle:handle];
        }];
    }];
}



@end
