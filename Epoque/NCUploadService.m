//
//  NCUploadService.m
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCUploadService.h"
#import <AFNetworking/AFNetworking.h>
#import <AWSS3.h>
@implementation NCUploadService

+(id)sharedInstance{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc]init];
    });
    return _sharedObject;
}


-(RACSignal *)uploadImage:(UIImage *)image{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *postUrl = @"https://forwardme.herokuapp.com/api/images/upload";
        AFHTTPRequestOperation *operation = [manager POST:postUrl parameters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"image" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *imageUrl = [responseObject objectForKey:@"imageUrl"];
            [subscriber sendNext:imageUrl];
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
