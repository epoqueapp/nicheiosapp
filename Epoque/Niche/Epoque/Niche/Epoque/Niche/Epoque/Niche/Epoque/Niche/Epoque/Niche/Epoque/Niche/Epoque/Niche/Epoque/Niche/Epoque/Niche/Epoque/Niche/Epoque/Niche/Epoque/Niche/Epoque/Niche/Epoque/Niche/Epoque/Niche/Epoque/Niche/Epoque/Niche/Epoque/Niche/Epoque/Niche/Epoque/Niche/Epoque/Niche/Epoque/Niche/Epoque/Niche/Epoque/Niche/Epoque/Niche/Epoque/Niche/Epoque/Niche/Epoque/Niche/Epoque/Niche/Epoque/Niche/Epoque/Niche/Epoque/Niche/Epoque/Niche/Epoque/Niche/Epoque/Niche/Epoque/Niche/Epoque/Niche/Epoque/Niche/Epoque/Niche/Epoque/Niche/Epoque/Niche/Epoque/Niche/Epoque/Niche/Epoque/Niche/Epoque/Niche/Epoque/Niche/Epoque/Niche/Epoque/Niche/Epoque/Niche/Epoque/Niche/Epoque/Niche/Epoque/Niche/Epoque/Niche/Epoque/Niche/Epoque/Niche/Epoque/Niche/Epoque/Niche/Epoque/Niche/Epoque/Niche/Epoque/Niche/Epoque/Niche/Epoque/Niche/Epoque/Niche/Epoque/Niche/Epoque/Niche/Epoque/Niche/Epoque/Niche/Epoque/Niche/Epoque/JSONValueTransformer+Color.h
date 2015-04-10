//
//  JSONValueTransformer+Color.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/5/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "JSONValueTransformer.h"

@interface JSONValueTransformer (Color)

-(UIColor*)UIColorFromNSString:(NSString*)string;
-(id)JSONObjectFromUIColor:(UIColor*)color;

@end
