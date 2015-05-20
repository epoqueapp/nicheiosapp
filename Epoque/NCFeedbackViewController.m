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
    [Amplitude logEvent:@"Send Feedback Button Did Click"];
    [NCLoadingView showInView:self.view withTitleText:@"sending"];
    UserModel *myUserModel = [NSUserDefaults standardUserDefaults].userModel;
    
    NSDictionary *body = @{
                           @"userId": myUserModel.userId,
                           @"userName": myUserModel.name,
                           @"userSpriteUrl": myUserModel.spriteUrl,
                           @"timestamp": kFirebaseServerValueTimestamp,
                           @"content": self.textView.text
                           };
    
    [[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"user-feedbacks"] childByAutoId] setValue:body withCompletionBlock:^(NSError *error, Firebase *ref) {
        @strongify(self);
        if (error) {
            [NCLoadingView hideAllFromView:self.view];
            [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"We ran into an error sending your feedback!" duration:2.0];
            return;
        }
        [NCLoadingView hideAllFromView:self.view];
        [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Your feedback was sent! Thank you" duration:2.0];
        
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
