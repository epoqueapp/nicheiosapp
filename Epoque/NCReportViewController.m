//
//  NCReportViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/13/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCReportViewController.h"
#import "NCUserService.h"
@interface NCReportViewController ()

@end

@implementation NCReportViewController{
    NCUserService *userService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    userService = [NCUserService sharedInstance];
    self.title = @"Report User";
    
    self.label.text = [NSString stringWithFormat:@"Report %@ for inappropriate behavior.", self.regardingUserName];
    self.textView.text = @"";
    [self setUpBackButton];
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc]initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendReport:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kTrocchiBoldFontName size:16.0]} forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

-(void)sendReport:(id)sender{
    @weakify(self);
    [NCLoadingView showInView:self.view];
    [[[[userService sendReport:self.regardingUserId content:self.textView.text] doNext:^(id x) {
        [NCLoadingView hideAllFromView:self.view];
        [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Thank you for helping us develop a great community." duration:2.0];
    }] delay:4.0] subscribeNext:^(id x) {
        @strongify(self);
        [self.navigationController popRetroViewController];
    } error:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        [self.navigationController popRetroViewController];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
