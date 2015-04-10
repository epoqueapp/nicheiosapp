//
//  SOLabel.h
//  Niche
//
//  Created by Maximilian Alexander on 3/22/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface SOLabel : UILabel

@property (nonatomic, readwrite) VerticalAlignment verticalAlignment;

@end