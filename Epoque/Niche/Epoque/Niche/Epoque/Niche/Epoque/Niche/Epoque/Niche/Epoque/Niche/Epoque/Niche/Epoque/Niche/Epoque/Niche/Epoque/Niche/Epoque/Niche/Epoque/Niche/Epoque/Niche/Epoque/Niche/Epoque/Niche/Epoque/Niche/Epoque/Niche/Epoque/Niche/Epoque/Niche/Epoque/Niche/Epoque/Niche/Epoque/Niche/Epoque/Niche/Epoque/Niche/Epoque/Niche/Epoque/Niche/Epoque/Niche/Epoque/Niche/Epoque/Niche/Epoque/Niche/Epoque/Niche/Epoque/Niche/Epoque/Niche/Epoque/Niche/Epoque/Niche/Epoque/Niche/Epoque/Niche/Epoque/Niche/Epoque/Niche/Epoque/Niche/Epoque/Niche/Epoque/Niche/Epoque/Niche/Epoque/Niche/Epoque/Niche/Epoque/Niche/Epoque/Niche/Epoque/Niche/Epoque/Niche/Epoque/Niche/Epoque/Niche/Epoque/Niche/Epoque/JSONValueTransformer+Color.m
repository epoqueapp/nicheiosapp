//
//  JSONValueTransformer+Color.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/5/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "JSONValueTransformer+Color.h"

@implementation JSONValueTransformer (Color)


-(UIColor *)UIColorFromNSString:(NSString *)string{
    return [UIColor colorWithHexString:string];
}


-(id)JSONObjectFromUIColor:(UIColor *)color{
    return [color hexStringFromColor];
}

@end
