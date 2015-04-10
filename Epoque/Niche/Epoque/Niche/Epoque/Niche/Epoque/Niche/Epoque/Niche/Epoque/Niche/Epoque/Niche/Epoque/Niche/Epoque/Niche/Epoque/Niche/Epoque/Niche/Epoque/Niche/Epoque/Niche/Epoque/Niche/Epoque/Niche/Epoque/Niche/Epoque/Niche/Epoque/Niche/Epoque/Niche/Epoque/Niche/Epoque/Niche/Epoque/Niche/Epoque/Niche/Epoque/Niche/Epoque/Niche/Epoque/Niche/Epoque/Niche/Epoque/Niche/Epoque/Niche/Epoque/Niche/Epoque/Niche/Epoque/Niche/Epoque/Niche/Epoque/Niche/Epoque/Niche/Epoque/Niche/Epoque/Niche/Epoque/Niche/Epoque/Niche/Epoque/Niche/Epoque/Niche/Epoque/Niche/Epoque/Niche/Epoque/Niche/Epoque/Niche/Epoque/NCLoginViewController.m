//
//  NCLoginViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//
#import "NCWorldsViewController.h"
#import "NCLoginViewController.h"
#import "NCLoginForm.h"
#import "NCFireService.h"
#import "NCUserService.h"
@interface NCLoginViewController ()

@end

@implementation NCLoginViewController{
    NCFireService *fireService;
    NCUserService *userService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    userService = [NCUserService sharedInstance];
    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.tableView;
    self.formController.delegate = self;
    self.formController.form = [[NCLoginForm alloc] init];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    self.loginButton.layer.cornerRadius = 3.0;
    [self setUpBackButton];
    fireService = [NCFireService sharedInstance];
    
    @weakify(self);
    
    RACCommand *loginCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        NCLoginForm *loginForm = (NCLoginForm *)self.formController.form;
        NSString *email = loginForm.email;
        NSString *password = loginForm.password;
        [[userService loginWithEmail:email password:password] subscribeNext:^(id x) {
            @strongify(self);
            NCWorldsViewController *worldViewController = [[NCWorldsViewController alloc]init];
            [self.navigationController pushViewController:worldViewController animated:YES];
        } error:^(NSError *error) {
            NSString *message = @"The email and password combination was not correct";
            switch (error.code) {
                case FAuthenticationErrorInvalidEmail:
                    message = @"This email was not in our system. Please make sure you've typed it correctly or create a new account";
                    break;
                case FAuthenticationErrorInvalidPassword:
                    message = @"You typed in the incorrect password!";
                    break;
                default:
                    message = @"The email and password was not found in our system";
                    break;
            }

            [[[UIAlertView alloc]initWithTitle:@"Uh Oh" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil]show];
        }];
        return [RACSignal empty];
    }];
    
    self.loginButton.rac_command = loginCommand;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
