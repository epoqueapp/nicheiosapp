//
//  UIViewController+BarButtons.m
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//
#import "UIViewController+BarButtons.h"
#import <RESideMenu/RESideMenu.h>
@implementation UIViewController (BarButtons)

-(void)setUpMenuButton{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonDidClick:)];
}

-(void)setUpBackButton{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonDidClick:)];
}

-(void)setUpDismissButtonWithTarget:(id)target selector:(SEL)selector{
    [self setUpDismissButtonWithTarget:target selector:selector buttonSide:DismissButtonSideRight];
}

-(void)setUpDismissButtonWithTarget:(id)target selector:(SEL)selector buttonSide:(DismissButtonSide)side{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close_icon"] style:UIBarButtonItemStylePlain target:target action:selector];
   
    if (side == DismissButtonSideLeft) {
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }else{
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    
}

-(void)menuButtonDidClick:(id)sender{
    [self.sideMenuViewController presentLeftMenuViewController];
    [Amplitude logEvent:@"Back Button Did Click"];
}

-(void)backButtonDidClick:(id)sender{
    [self.navigationController popRetroViewController];
    [Amplitude logEvent:@"Back Button Did Click"];
}



@end
