//
//  NSArray+RandomMethods.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/26/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NSArray+RandomMethods.h"

@implementation NSArray (RandomMethods)

- (id)randomObject
{
    id randomObject = [self count] ? self[arc4random_uniform((u_int32_t)[self count])] : nil;
    return randomObject;
}

@end
