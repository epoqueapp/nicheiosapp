//
//  UIViewController+BarButtons.m
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//
#import "NCWorldsViewController.h"
#import "UIViewController+BarButtons.h"
#import <RESideMenu/RESideMenu.h>
@implementation UIViewController (BarButtons)

-(void)setUpMenuButton{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonDidClick:)];
    
}

-(void)setUpBackButtonWithWorldsDefault{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonDidClickWithWorldsDefault:)];
}

-(void)setUpBackButtonWithConversationsDefault{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonDidClickWithWorldsDefault:)];
}

-(void)setUpBackButton{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonDidClick:)];
}

-(void)menuButtonDidClick:(id)sender{
    [self.sideMenuViewController presentLeftMenuViewController];
    [Amplitude logEvent:@"Back Button Did Click"];
}

-(void)backButtonDidClick:(id)sender{
    [self.navigationController popRetroViewController];
    [Amplitude logEvent:@"Back Button Did Click"];
}

-(void)backButtonDidClickWithWorldsDefault:(id)sender{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        NCWorldsViewController *worldsViewController = [[NCWorldsViewController alloc] init];
        [self.navigationController pushFadeViewController:worldsViewController];
    }else{
        [Amplitude logEvent:@"Back Button Did Click"];
        [self.navigationController popFadeViewController];
    }
}


@end
