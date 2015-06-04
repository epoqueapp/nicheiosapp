//
//  UINavigationController+PushPop.h
//  Epoque
//
//  Created by Maximilian Alexander on 4/5/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (PushPop)

-(void)pushFadeViewController:(UIViewController *)controller;
-(void)popFadeViewController;
-(void)pushRetroViewController:(UIViewController *)viewController;
-(void)popRetroViewController;

@end
