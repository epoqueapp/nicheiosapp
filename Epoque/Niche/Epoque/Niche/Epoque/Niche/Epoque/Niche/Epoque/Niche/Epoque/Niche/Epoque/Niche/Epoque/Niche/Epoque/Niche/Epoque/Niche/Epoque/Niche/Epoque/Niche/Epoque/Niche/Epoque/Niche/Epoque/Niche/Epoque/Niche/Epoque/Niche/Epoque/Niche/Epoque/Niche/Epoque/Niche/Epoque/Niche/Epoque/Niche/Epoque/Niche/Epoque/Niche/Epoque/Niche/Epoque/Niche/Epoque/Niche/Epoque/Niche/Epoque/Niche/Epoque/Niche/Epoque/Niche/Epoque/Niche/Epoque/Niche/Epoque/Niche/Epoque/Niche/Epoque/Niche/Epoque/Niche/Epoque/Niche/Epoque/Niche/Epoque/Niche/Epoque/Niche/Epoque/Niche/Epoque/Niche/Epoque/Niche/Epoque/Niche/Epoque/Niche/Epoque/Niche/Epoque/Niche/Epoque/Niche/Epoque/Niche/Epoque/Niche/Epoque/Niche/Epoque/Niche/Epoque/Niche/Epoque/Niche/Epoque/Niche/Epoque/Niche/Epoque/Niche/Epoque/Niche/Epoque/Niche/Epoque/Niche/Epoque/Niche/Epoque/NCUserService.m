//
//  NCUserService.m
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//




#import "NCUserService.h"
#import <AFNetworking-RACExtensions/AFHTTPRequestOperationManager+RACSupport.h>
#import "AFHTTPRequestOperationManager+EpoqueManager.h"
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

-(RACSignal *)loginWithEmail:(NSString *)email password:(NSString *)password{
    NSDictionary *payload = @{
                              @"email": email,
                              @"password": password
                              };
    
    NSString *loginUrl = [apiRootUrl stringByAppendingString:@"/login/external"];
    return [[[AFHTTPRequestOperationManager manager] rac_POST:loginUrl parameters:payload] doNext:^(id x) {
        UserModel *userModel = [[UserModel alloc]initWithDictionary:[x objectForKey:@"user"] error:nil];
        [[NSUserDefaults standardUserDefaults] setUserModel:userModel];
        [[NSUserDefaults standardUserDefaults] setAccessToken:[x objectForKey:@"accessToken"]];
    }];
}

-(RACSignal *)loginWithFacebookAccessToken:(NSString *)facebookAccessToken spriteUrl:(NSString *)spriteUrl{
    NSDictionary *payload = @{
                              @"facebookAccessToken": facebookAccessToken,
                              @"spriteUrl": spriteUrl
                              };
    
    NSString *loginUrl = [apiRootUrl stringByAppendingString:@"/login/facebook"];
    return [[[AFHTTPRequestOperationManager manager] rac_POST:loginUrl parameters:payload] doNext:^(id x) {
        UserModel *userModel = [[UserModel alloc]initWithDictionary:[x objectForKey:@"user"] error:nil];
        [[NSUserDefaults standardUserDefaults] setUserModel:userModel];
        [[NSUserDefaults standardUserDefaults] setAccessToken:[x objectForKey:@"accessToken"]];
    }];
}

-(RACSignal *)signupWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name about:(NSString *)about spriteUrl:(NSString *)spriteUrl imageUrl:(NSString *)imageUrl{
    if (imageUrl == nil) {
        imageUrl = @"";
    }
    
    NSDictionary *payload = @{
                              @"email": email,
                              @"password": password,
                              @"name": name,
                              @"about": about,
                              @"spriteUrl": spriteUrl,
                              @"imageUrl": imageUrl
                              };
    
    NSString *signupUrl = [apiRootUrl stringByAppendingString:@"/signup"];
    return [[[AFHTTPRequestOperationManager manager] rac_POST:signupUrl parameters:payload] doNext:^(id x) {
        UserModel *userModel = [[UserModel alloc]initWithDictionary:[x objectForKey:@"user"] error:nil];
        [[NSUserDefaults standardUserDefaults] setUserModel:userModel];
        [[NSUserDefaults standardUserDefaults] setAccessToken:[x objectForKey:@"accessToken"]];
    }];
}

-(RACSignal *)updateMe:(UserModel *)userModel{
    NSDictionary *payload = @{
                              @"email": userModel.email,
                              @"name": userModel.name,
                              @"about": userModel.about,
                              @"spriteUrl": userModel.spriteUrl,
                              @"imageUrl": userModel.imageUrl
                              };
    NSString *url = [[apiRootUrl stringByAppendingString:@"/users/"] stringByAppendingString:userModel.userId];
    return [[[[AFHTTPRequestOperationManager epoqueManager] rac_PUT:url parameters:payload] map:^id(id value) {
        UserModel *updatedUserModel = [[UserModel alloc]initWithDictionary:value error:nil];
        return updatedUserModel;
    }] doNext:^(UserModel *updatedUserModel) {
        [[NSUserDefaults standardUserDefaults] setUserModel:updatedUserModel];
    }];
}

-(RACSignal *)sendFeedbackWithContent:(NSString *)content{
    NSDictionary *payload = @{
                              @"content": content
                              };
    NSString *url = [apiRootUrl stringByAppendingString:@"/userfeedbacks"];
    return [[AFHTTPRequestOperationManager epoqueManager] rac_POST:url parameters:payload];
}

-(RACSignal *)getMembersByWorldId:(NSString *)worldId{
    NSString *url = [NSString stringWithFormat:@"%@/worlds/%@/members", apiRootUrl, worldId];
    return [[[AFHTTPRequestOperationManager epoqueManager] rac_GET:url parameters:nil] map:^id(id value) {
        NSArray *users = [UserModel arrayOfModelsFromDictionaries:value];
        return users;
    }];
}

-(RACSignal *)updatePushNotificationToken:(NSString *)deviceToken{
    NSString *url = [NSString stringWithFormat:@"%@/ios", apiRootUrl];
    
    NSDictionary *json = @{@"environment": kNCAPSEnvironment, @"deviceToken": deviceToken};
    
    return [[AFHTTPRequestOperationManager epoqueManager] rac_PUT:url parameters:json];
}

@end
