//
//  RESideMenu+CustomSetContentMethods.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/25/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "RESideMenu+CustomSetContentMethods.h"
#import "NCMapViewController.h"
#import "NCNavigationController.h"
@implementation RESideMenu (CustomSetContentMethods)


-(void)clearPossibleMaps{
    if([self.contentViewController isKindOfClass:[NCNavigationController class]]){
        NSArray *viewControllers = ((NCNavigationController *)self.contentViewController).viewControllers;
        for (UIViewController *controller in viewControllers) {
            if ([controller isKindOfClass:[NCMapViewController class]]) {
                NCMapViewController *mapController = (NCMapViewController *)controller;
                [mapController clearMap];
            }
        }
    }
}

-(void)customSetContentViewController:(UIViewController *)contentViewController{
    [self clearPossibleMaps];
    [self setContentViewController:contentViewController];
}

-(void)customSetContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated{
    [self clearPossibleMaps];
    [self setContentViewController:contentViewController animated:animated];
}

@end
