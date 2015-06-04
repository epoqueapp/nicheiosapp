//
//  UIViewController+BarButtons.h
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DismissButtonSideLeft,
    DismissButtonSideRight
} DismissButtonSide;

@interface UIViewController (BarButtons)

-(void)setUpMenuButton;
-(void)setUpBackButton;
-(void)setUpDismissButtonWithTarget:(id)target selector:(SEL)selector;
-(void)setUpDismissButtonWithTarget:(id)target selector:(SEL)selector buttonSide:(DismissButtonSide)side;

@end
