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
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
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

-(RACSignal *)uploadImageToAmazon:(NSURL *)imageLocalUrl{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = @"epoque-uploads";
        
        NSString *fileName = [[[NSUUID UUID] UUIDString] stringByAppendingString:@".jpg"];
        
        uploadRequest.key = fileName;
        uploadRequest.body = imageLocalUrl;
        
        [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if (task.error) {
                if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                    switch (task.error.code) {
                        case AWSS3TransferManagerErrorCancelled:
                        case AWSS3TransferManagerErrorPaused:
                            break;
                            
                        default:
                            NSLog(@"Error: %@", task.error);
                            break;
                    }
                } else {
                    // Unknown error.
                    NSLog(@"Error: %@", task.error);
                }
                [subscriber sendError:task.error];
            }
            
            if (task.result) {
                AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                [subscriber sendNext:uploadOutput];
                [subscriber sendCompleted];
            }
            return nil;
        }];
        return nil;
    }];
}

@end
