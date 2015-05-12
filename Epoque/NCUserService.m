//
//  NCUserService.m
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//




#import "NCUserService.h"
#import <AFNetworking-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>
@implementation NCUserService{
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


-(RACSignal *)sendFeedbackWithContent:(NSString *)content{
    UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
    NSDictionary *payload = @{
                              @"email": userModel.email,
                              @"userName": userModel.name,
                              @"content": content
                              };
    NSString *url = [apiRootUrl stringByAppendingString:@"/userfeedbacks"];
    return [[AFHTTPRequestOperationManager manager] rac_POST:url parameters:payload];
}


-(RACSignal *)sendReport:(NSString *)userId content:(NSString *)content{
    NSString *url= [NSString stringWithFormat:@"%@/reports", apiRootUrl];
    UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
    return [[[AFHTTPRequestOperationManager manager] rac_PUT:url parameters:@{@"reporteeUserId": userId, @"content": content, @"reporterUserId": userModel.userId, @"reporterUserName": userModel.name}] map:^id(id value) {
        return [[WorldModel alloc] initWithDictionary:value error:nil];
    }];
}

@end
