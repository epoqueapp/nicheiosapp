//
//  UIColor+LovelyColors.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/16/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "UIColor+LovelyColors.h"

@implementation UIColor (LovelyColors)

+(UIColor *)lovelyBlue{
    return [UIColor colorWithRed:0 green:127.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+(UIColor *)lovelyBlueWithAlpha:(float)alpha{
    return [UIColor colorWithRed:0 green:127.0/255.0 blue:255.0/255.0 alpha:alpha];
}

@end
