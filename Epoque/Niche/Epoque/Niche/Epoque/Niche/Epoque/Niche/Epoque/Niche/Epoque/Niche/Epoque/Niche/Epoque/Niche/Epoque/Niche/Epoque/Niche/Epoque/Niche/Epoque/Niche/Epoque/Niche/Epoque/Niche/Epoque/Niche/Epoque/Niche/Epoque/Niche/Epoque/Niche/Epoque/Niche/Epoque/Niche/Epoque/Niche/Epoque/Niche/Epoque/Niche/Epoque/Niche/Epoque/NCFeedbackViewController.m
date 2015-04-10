//
//  NCFeedbackViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 3/31/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCFeedbackViewController.h"
#import "NCUserService.h"
#import <RESideMenu/RESideMenu.h>
@interface NCFeedbackViewController ()

@end

@implementation NCFeedbackViewController{
    NCUserService *userService;
    Mixpanel *mixpanel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Send Feedback";
    [self setUpMenuButton];
    userService = [NCUserService sharedInstance];
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc]initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendFeedback:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kTrocchiBoldFontName size:16.0]} forState:UIControlStateNormal];
}

-(void)sendFeedback:(id)sender{
    @weakify(self);
    [self.textView resignFirstResponder];
    [mixpanel timeEvent:@"Send Feedback"];
    [NCLoadingView showInView:self.view withTitleText:@"sending"];
    [[userService sendFeedbackWithContent:self.textView.text] subscribeNext:^(id x) {
        @strongify(self);
        [mixpanel track:@"Send Feedback" properties:@{@"content": self.textView.text}];
        [NCLoadingView hideAllFromView:self.view];
        [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Your feedback was sent! Thank you" duration:2.0];
    } error:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"We ran into an error sending your feedback!" duration:2.0];
    }];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
