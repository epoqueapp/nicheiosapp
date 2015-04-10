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

-(void)menuButtonDidClick:(id)sender{
    [self.sideMenuViewController presentLeftMenuViewController];
    [[Mixpanel sharedInstance] track:@"Back Button Did Click"];
}

-(void)backButtonDidClick:(id)sender{
    [self.navigationController popRetroViewController];
    [[Mixpanel sharedInstance] track:@"Back Button Did Click"];
}

@end
