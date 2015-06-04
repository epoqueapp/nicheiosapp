//
//  NCUploadService.m
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCUploadService.h"
#import <AFNetworking/AFNetworking.h>
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
    CLCloudinary *cloudinary = [[CLCloudinary alloc] init];
    [cloudinary.config setValue:@"zinkpulse" forKey:@"cloud_name"];
    [cloudinary.config setValue:@"138756628856888" forKey:@"api_key"];
    [cloudinary.config setValue:@"fZ4jvzPOUTSA34OV7KPTdPhUH6k" forKey:@"api_secret"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CLUploader* uploader = [[CLUploader alloc] init:cloudinary delegate:self];
        [uploader upload:imageData options:@{@"resource_type": @"raw"} withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
            if (successResult) {
                NSString* imageUrl = [successResult valueForKey:@"secure_url"];
                [subscriber sendNext:imageUrl];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError errorWithDomain:@"Cloudinary" code:code userInfo:@{@"errorResult": errorResult}]];
                
            }
        } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
            //NSLog(@"Block upload progress: %ld/%ld (+%ld)", (long)totalBytesWritten, (long)totalBytesExpectedToWrite, (long)bytesWritten);
        }];
        return nil;
    }] deliverOn:[RACScheduler scheduler]];
}


@end
