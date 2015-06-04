//
//  NSString+StringAdditions.m
//  Niche
//
//  Created by Maximilian Alexander on 3/30/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NSString+StringAdditions.h"

@implementation NSString (StringAdditions)

+ (BOOL)isStringEmpty:(NSString *)string {
    if([string length] == 0) { //string is empty or nil
        return YES;
    }
    if(![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        //string is all whitespace
        return YES;
    }
    return NO;
}

+(NSString *)generateRandomPIN:(NSInteger)places{
    NSString *alphabet  = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:places];
    for (NSUInteger i = 0U; i < places; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}

+(NSString *)randomImageEmoji{
    NSDictionary *imageEmoji = @{
                                 @"\U0001F303": @"night with stars",
                                 @"\U0001F320": @"shooting star",
                                 @"\U0001F4F7": @"camera",
                                 };
    
    NSArray *array = [imageEmoji allKeys];
    int random = arc4random()%[array count];
    NSString *key = [array objectAtIndex:random];
    return [key copy];
}

+(NSString *)speechBubbleEmoji{
    return @"\U0001F4AC";
}

@end
