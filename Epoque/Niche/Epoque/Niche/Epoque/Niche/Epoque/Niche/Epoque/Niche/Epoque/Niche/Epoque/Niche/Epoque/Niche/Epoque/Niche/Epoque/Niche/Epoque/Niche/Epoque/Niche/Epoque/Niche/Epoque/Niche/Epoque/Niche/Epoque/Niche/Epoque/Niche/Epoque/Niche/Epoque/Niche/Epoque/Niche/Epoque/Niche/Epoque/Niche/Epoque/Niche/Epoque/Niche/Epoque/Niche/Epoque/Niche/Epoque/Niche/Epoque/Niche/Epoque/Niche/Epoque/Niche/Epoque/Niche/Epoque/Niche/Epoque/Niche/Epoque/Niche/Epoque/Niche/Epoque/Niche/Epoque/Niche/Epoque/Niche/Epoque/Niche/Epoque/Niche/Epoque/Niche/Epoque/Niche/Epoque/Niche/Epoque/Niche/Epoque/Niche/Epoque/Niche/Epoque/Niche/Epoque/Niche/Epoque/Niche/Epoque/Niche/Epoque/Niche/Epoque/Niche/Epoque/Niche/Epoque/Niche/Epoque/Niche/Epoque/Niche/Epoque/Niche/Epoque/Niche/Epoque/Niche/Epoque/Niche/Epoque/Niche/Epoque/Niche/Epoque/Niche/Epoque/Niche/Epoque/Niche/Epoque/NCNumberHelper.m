//
//  NCNumberHelper.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/5/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCNumberHelper.h"

@implementation NCNumberHelper

+(float)randomFloatBetweenMinRange:(float)minRange maxRange:(float)maxRange{
    float randomNumber = ((float)arc4random() / ARC4RANDOM_MAX * (maxRange - minRange)) + minRange;
    return randomNumber;
}

@end
