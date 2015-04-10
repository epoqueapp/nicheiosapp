//
//  UIColor+HexString.m
//  Niche
//
//  Created by Maximilian Alexander on 3/25/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "UIColor+HexString.h"

@implementation UIColor (HexString)

- (NSString *)hexStringFromColor{
    if (!self) {
        return nil;
    }
    
    if (self == [UIColor whiteColor]) {
        // Special case, as white doesn't fall into the RGB color space
        return @"#ffffff";
    }
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    int redDec = (int)(red * 255);
    int greenDec = (int)(green * 255);
    int blueDec = (int)(blue * 255);
    NSString *returnString = [NSString stringWithFormat:@"#%02x%02x%02x", (unsigned int)redDec, (unsigned int)greenDec, (unsigned int)blueDec];
    return returnString;
}

+ (UIColor *) colorWithHexString: (NSString *) hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    
    NSLog(@"colorString :%@",colorString);
    CGFloat alpha, red, blue, green;
    
    // #RGB
    alpha = 1.0f;
    red   = [self colorComponentFrom: colorString start: 0 length: 2];
    green = [self colorComponentFrom: colorString start: 2 length: 2];
    blue  = [self colorComponentFrom: colorString start: 4 length: 2];
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end
