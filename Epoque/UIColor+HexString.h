//
//  UIColor+HexString.h
//  Niche
//
//  Created by Maximilian Alexander on 3/25/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

- (NSString *)hexStringFromColor;
+ (UIColor *)colorWithHexString: (NSString *)hexString;
+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end
