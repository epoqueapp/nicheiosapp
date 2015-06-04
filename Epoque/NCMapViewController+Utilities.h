//
//  NCMapViewController+Utilities.h
//  Epoque
//
//  Created by Maximilian Alexander on 5/26/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController.h"

@interface NCMapViewController (Utilities)

-(void)setChatPreviewViewWithUserId:(NSString *)userId spriteUrl:(NSString *)spriteUrl name:(NSString *)name messageText:(NSString *)messageText messageImageUrl:(NSString *)messageImageUrl timestamp:(NSDate*)timestamp backgroundColor:(UIColor *)backgroundColor;

@end
