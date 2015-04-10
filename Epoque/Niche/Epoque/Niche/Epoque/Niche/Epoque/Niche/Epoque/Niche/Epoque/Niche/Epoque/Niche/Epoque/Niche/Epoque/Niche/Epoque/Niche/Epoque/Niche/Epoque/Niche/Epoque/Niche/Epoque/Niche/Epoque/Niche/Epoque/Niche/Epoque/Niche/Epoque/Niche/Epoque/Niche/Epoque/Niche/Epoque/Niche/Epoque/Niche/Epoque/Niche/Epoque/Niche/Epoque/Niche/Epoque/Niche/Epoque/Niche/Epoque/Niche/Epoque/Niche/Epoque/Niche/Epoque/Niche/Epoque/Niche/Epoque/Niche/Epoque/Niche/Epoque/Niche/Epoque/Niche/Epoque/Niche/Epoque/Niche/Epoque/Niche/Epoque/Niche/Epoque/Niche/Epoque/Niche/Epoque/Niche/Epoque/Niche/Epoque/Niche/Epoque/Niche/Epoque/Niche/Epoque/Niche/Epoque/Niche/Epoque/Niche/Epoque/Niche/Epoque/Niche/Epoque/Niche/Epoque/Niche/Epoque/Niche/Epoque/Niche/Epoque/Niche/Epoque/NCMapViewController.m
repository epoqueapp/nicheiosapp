//
//  NCWorldMapViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMapViewController.h"
#import "NCFireService.h"
@interface NCMapViewController ()

@end

@implementation NCMapViewController{
    NCFireService *fireService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton];
    fireService = [NCFireService sharedInstance];
    
    self.textInputbar = [[SLKTextInputbar alloc]initWithTextViewClass:[SLKTextView class]];
    self.textInputbar.translatesAutoresizingMaskIntoConstraints = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
