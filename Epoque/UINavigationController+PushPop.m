//
//  UINavigationController+PushPop.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/5/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "UINavigationController+PushPop.h"
#import "NCWorldsViewController.h"
@implementation UINavigationController (PushPop)

-(void)pushFadeViewController:(UIViewController *)controller{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    //transition.subtype = kCATransitionFromTop;
    
    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self pushViewController:controller animated:NO];
}

-(void)popFadeViewController{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    //transition.subtype = kCATransitionFromTop;

    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self popViewControllerAnimated:NO];
}

- (void)pushRetroViewController:(UIViewController *)viewController {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.layer addAnimation:transition forKey:nil];
    
    [self pushViewController:viewController animated:NO];
}

- (void)popRetroViewController {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:transition forKey:nil];
    [self popViewControllerAnimated:NO];
}

- (void)goToWorldsController{
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for (int i = 0; i < [viewControllers count]; i++){
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[NCWorldsViewController class]]){
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
    }
}


@end
