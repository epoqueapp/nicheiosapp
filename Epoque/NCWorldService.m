//
//  NCWorldService.m
//  Niche
//
//  Created by Maximilian Alexander on 3/29/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldService.h"
#import <AFNetworking-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>
#import "AFHTTPRequestOperationManager+EpoqueManager.h"
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
    self = [super init] ;
    if (self) {
        apiRootUrl = @"https://prod.epoquecore.com";
    }
    return self;
}


-(RACSignal *)createWorld:(WorldModel *)worldModel{
    NSDictionary *payload = @{
                              @"name": worldModel.name,
                              @"detail": worldModel.detail,
                              @"isPrivate": @(worldModel.isPrivate),
                              @"tags": worldModel.tags,
                              @"imageUrl": worldModel.imageUrl
                              };
    NSString *postUrl = [apiRootUrl stringByAppendingString:@"/worlds"];
    return [[AFHTTPRequestOperationManager epoqueManager] rac_POST:postUrl parameters:payload];
}

-(RACSignal *)updateWorld:(WorldModel *)worldModel{
    NSString *worldId = worldModel.worldId;
    NSString *putUrl = [[apiRootUrl stringByAppendingString:@"/worlds/"] stringByAppendingString:worldId];
    
    NSDictionary *payload = @{
                              @"name": worldModel.name,
                              @"detail": worldModel.detail,
                              @"isPrivate": @(worldModel.isPrivate),
                              @"isDefault": @(worldModel.isDefault),
                              @"tags": @[],
                              @"imageUrl": worldModel.imageUrl
                              };
    
    return [[AFHTTPRequestOperationManager epoqueManager] rac_PUT:putUrl parameters:payload];
}

-(RACSignal *)getMyWorlds{
    NSString *getMyWorldsUrl = [apiRootUrl stringByAppendingString:@"/users/me/worlds"];
    return [[[AFHTTPRequestOperationManager epoqueManager] rac_GET:getMyWorldsUrl parameters:nil] map:^id(id value) {
        NSArray *worldModels = [WorldModel arrayOfModelsFromDictionaries:value];
        return worldModels;
    }];
}

-(RACSignal *)deleteWorldWithId:(NSString *)worldId{
    NSString *deleteUrl = [[apiRootUrl stringByAppendingString:@"/worlds/"] stringByAppendingString:worldId];
    return [[AFHTTPRequestOperationManager epoqueManager] rac_DELETE:deleteUrl parameters:nil];
}

-(RACSignal *)getWorldById:(NSString *)worldId{
    NSString *url = [[apiRootUrl stringByAppendingString:@"/worlds/"] stringByAppendingString:worldId];
    return [[[AFHTTPRequestOperationManager epoqueManager] rac_GET:url parameters:nil] map:^id(id value) {
        return [[WorldModel alloc]initWithDictionary:value error:nil];
    }];
}

-(RACSignal *)joinWorldById:(NSString *)worldId{
    NSString *url = [NSString stringWithFormat:@"%@/worlds/%@/join", apiRootUrl, worldId];
    return [[[AFHTTPRequestOperationManager epoqueManager] rac_PUT:url parameters:nil] map:^id(id value) {
        return [[WorldModel alloc]initWithDictionary:value error:nil];
    }];
}

-(RACSignal *)unjoinWorldById:(NSString *)worldId{
    NSString *url = [NSString stringWithFormat:@"%@/worlds/%@/unjoin", apiRootUrl, worldId];
    return [[[AFHTTPRequestOperationManager epoqueManager] rac_PUT:url parameters:nil] map:^id(id value) {
        return [[WorldModel alloc]initWithDictionary:value error:nil];
    }];
}

-(RACSignal *)searchWorlds:(NSString *)searchTerm{
    NSString *getUrl = [apiRootUrl stringByAppendingString:@"/worlds"];
    return [[AFHTTPRequestOperationManager epoqueManager] rac_GET:getUrl parameters:@{@"searchTerm": searchTerm}];
}

@end
