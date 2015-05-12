//
//  NCWorldService.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/3/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldService.h"
#import "WorldModel.h"
#import <AFNetworking-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>
@implementation NCWorldService{
    NSString *apiRootUrl;
}

+(id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc]init];
    });
    return _sharedObject;
}

-(id)init{
    self = [super init];
    if (self) {
        apiRootUrl = @"https://prod.epoquecore.com";
    }
    return self;
}

-(RACSignal *)getFavoritedWorlds {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@epoque/world/_search", kBonsaiRoot];
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    NSDictionary *parameters = @{
                                 @"query": @{
                                         @"filtered": @{
                                             @"filter": @{
                                                     @"term": @{
                                                             @"favoritedUserIds": myUserId}
                                             }
                                        }
                                    }
                                 };
    
    
    return [[manager rac_POST:url parameters:parameters] map:^id(id value) {
        NSArray *hits = value[@"hits"][@"hits"];
        NSMutableArray *worlds = [NSMutableArray array];
        for (NSDictionary *dic in hits) {
            WorldModel *worldModel = [[WorldModel alloc]initWithHit:dic];
            [worlds addObject:worldModel];
        }
        return worlds;
    }];
}

-(RACSignal *)getDefaultWorlds {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@epoque/world/_search", kBonsaiRoot];
    NSDictionary *parameters = @{
                                 @"query": @{
                                         @"filtered": @{
                                                 @"filter": @{
                                                         @"term": @{
                                                                 @"isDefault": @"true"}
                                                         }
                                                 }
                                         }
                                 };
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AFHTTPRequestOperation *operation = [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *hits = responseObject[@"hits"][@"hits"];
            NSMutableArray *worlds = [NSMutableArray array];
            for (NSDictionary *dic in hits) {
                WorldModel *worldModel = [[WorldModel alloc]initWithHit:dic];
                [worlds addObject:worldModel];
            }
            [subscriber sendNext:worlds];
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
}

-(RACSignal *)searchWorlds:(NSString *)searchTerm{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@epoque/world/_search", kBonsaiRoot];
    NSDictionary *parameters = @{
                                 @"query": @{
                                         @"fuzzy_like_this": @{
                                                 @"fields": @[@"name", @"detail"],
                                                 @"like_text": searchTerm,
                                                 @"max_query_terms": @(24),
                                                 @"fuzziness": @(2)
                                         }
                                         }
                                 };
    
    
                                 return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                                     AFHTTPRequestOperation *operation = [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSArray *hits = responseObject[@"hits"][@"hits"];
                                         NSMutableArray *worlds = [NSMutableArray array];
                                         for (NSDictionary *dic in hits) {
                                             WorldModel *worldModel = [[WorldModel alloc]initWithHit:dic];
                                             [worlds addObject:worldModel];
                                         }
                                         [subscriber sendNext:worlds];
                                         [subscriber sendCompleted];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [subscriber sendError:error];
                                     }];
                                     return [RACDisposable disposableWithBlock:^{
                                         [operation cancel];
                                     }];
                                 }]; 
}

@end
