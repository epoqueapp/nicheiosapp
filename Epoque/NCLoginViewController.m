//
//  NCLoginViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCLoginViewController.h"
#import "Firebase+AuthenticationExtensions.h"
#import "NCMapViewController.h"
@interface NCLoginViewController ()

@end

@implementation NCLoginViewController{
    NSString *cachedEmail;
    NSString *cachedPassword;
}

static NSString *const kForgotPasswordSendTitle = @"Send";
static NSString *const kChangePasswordTitle = @"Change";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpBackButton];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    NCLoginForm *form = [[NCLoginForm alloc] init];
    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.tableView;
    self.formController.delegate = self;
    self.formController.form = form;
    
    self.title = @"Existing Account";
    
    [self.forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)forgotPasswordButtonDidTap:(id)sender{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Forgot password?"
                                                                   message:@"What email was used with your account?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UITextField *emailTextField = alert.textFields.firstObject;
                                                              NSString *email = emailTextField.text;
                                                              [self attemptToSendForgotPasswordEmail:email];
                                                          }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Email Address", @"Email");
     }];
    [alert addAction:defaultAction];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)attemptToSendForgotPasswordEmail:(NSString *)emailAddress{
    @weakify(self);
    [NCLoadingView showInView:self.view];
    [[[[Firebase alloc]initWithUrl:kFirebaseRoot] rac_sendPasswordResetForEmail:emailAddress] subscribeNext:^(id x) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        NSString *errorMessage = @"Hey check your email!";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } error:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        NSString *errorMessage = @"Ran into an issue sending you an email";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

-(void)attemptToChangePasswordForEmaiL:(NSString *)email oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword{
    Firebase *firebase = [[Firebase alloc]initWithUrl:kFirebaseRoot];
    RACSignal *changeSignal = [firebase rac_changePasswordForEmail:email oldPassword:oldPassword newPassword:newPassword];
    
    @weakify(self);
    [changeSignal subscribeNext:^(id x) {
        @strongify(self);
        [self attemptToLoginWith:email password:newPassword];
    } error:^(NSError *error) {
        
    }];
}

-(void)attemptToLoginWith:(NSString *)email password:(NSString *)password {
    @weakify(self);
    Firebase *firebase = [[Firebase alloc]initWithUrl:kFirebaseRoot];
    [NCLoadingView showInView:self.view];
    [[firebase rac_loginWithEmail:email password:password] subscribeNext:^(id x) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        NCMapViewController *mapViewController = [[NCMapViewController alloc]init];
        mapViewController.worldId = kOpenWorldTitle;
        [self.navigationController pushFadeViewController:mapViewController];
    } error:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        NSString *errorMessage = @"Couldn't log you in!";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        switch(error.code) {
            case FAuthenticationErrorEmailTaken:{
                errorMessage = @"This email is already taken. Try Logging in?";
                break;
            }
            case FAuthenticationErrorInvalidEmail:{
                errorMessage = @"Your email wasn't in the right format. Check carefully!";
                break;
            }
            case FAuthenticationErrorUserDoesNotExist:{
                errorMessage = @"We couldn't find a user with that email. Check carefully!";
                break;
            }
            case FAuthenticationErrorInvalidPassword:{
                errorMessage = @"Your password wasn't correct!";
                break;
            }
            case kNCAuthenticationTemporaryPasswordErrorCode:{
                errorMessage = @"Okay that was a temporary password. Now change it to something you would remember";
                cachedEmail = [email copy];
                cachedPassword = [email copy];
                
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
                 {
                     textField.placeholder = NSLocalizedString(@"New Password", @"Password");
                 }];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"Change Password" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSString *newPassword = ((UITextField *)alertController.textFields.firstObject).text;
                    [self attemptToChangePasswordForEmaiL:cachedEmail oldPassword:cachedPassword newPassword:newPassword];
                }]];
                break;
            }
            default:{
                errorMessage = @"We ran into a big issue. We're on it.";
                break;
            }
        }
        alertController.message = errorMessage;
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

-(void)submitButtonDidTap{
    NCLoginForm *form = (NCLoginForm *)self.formController.form;
    if (!form.isValid) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"\U0001F613 Don't cheat. Fill everything out." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        return;
    }
    [self attemptToLoginWith:form.email password:form.password];
}

@end
