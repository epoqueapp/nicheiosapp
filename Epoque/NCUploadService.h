//
//  NCUploadService.h
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCUploadService : NSObject

+(id)sharedInstance;

-(RACSignal *)uploadImage:(UIImage *)image;

-(RACSignal *)uploadImageToAmazon:(UIImage *)image;

@end
