//
//  NCNameChoiceViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/14/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCNameChoiceViewController.h"
#import "Firebase+AuthenticationExtensions.h"
#import "NCLoginViewController.h"
#import "NCMapViewController.h"
#import "NCCreateUserForm.h"
#import "NCFireService.h"
#import <MBFaker/MBFaker.h>
@interface NCNameChoiceViewController ()

@end

@implementation NCNameChoiceViewController{
    NCFireService *fireService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    fireService = [NCFireService sharedInstance];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    NCCreateUserForm *form = [[NCCreateUserForm alloc] init];
    form.spriteUrl = self.spriteUrl;
    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.tableView;
    self.formController.delegate = self;
    self.formController.form = form;
    
    [self.loginButton addTarget:self action:@selector(loginButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)loginButtonDidTap:(id)sender{
    NCLoginViewController *loginViewController = [[NCLoginViewController alloc]init];
    [self.navigationController pushFadeViewController:loginViewController];
}

-(void)spriteDidTap{
    NCSpritesViewController *spritesViewController = [[NCSpritesViewController alloc]init];
    spritesViewController.delegate = self;
    [self presentViewController:spritesViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didSelectSpriteFromModal:(NSString *)spriteUrl{
    self.spriteUrl = [spriteUrl copy];
    ((NCCreateUserForm *)self.formController.form).spriteUrl = spriteUrl;
    [self.tableView reloadData];
}

-(RACSignal *)addMarketingSignupWithEmail:(NSString *)email{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"marketing-signups"] childByAutoId] setValue:@{@"email": email, @"referral": @"ios", @"timestamp": kFirebaseServerValueTimestamp} withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendNext:error];
            }else{
                [subscriber sendNext:email];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}



-(void)submitButtonDidTap{
    NCCreateUserForm *form = (NCCreateUserForm *)self.formController.form;
    if (!form.isValid) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"I know you're excited. \U0001F613 Don't cheat. Fill everything out." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show];
        return;
    }
    @weakify(self);
    [NCLoadingView showInView:self.view];
    
    NSString *email = form.email;
    NSString *name = [form.name stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *password = form.password;
    
    
    Firebase *ref = [[Firebase alloc]initWithUrl:kFirebaseRoot];
    
    [[[[ref rac_validateName:name] flattenMap:^RACStream *(id value) {
        return [ref rac_createUserWithEmail:email password:password name:name about:@"" spriteUrl:form.spriteUrl role:@"normal"];
    }] flattenMap:^RACStream *(id value) {
        return [self addMarketingSignupWithEmail:form.email];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        NCMapViewController *mapViewController = [[NCMapViewController alloc]init];
        mapViewController.worldId = kOpenWorldTitle;
        [self.navigationController pushFadeViewController:mapViewController];
    } error:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        NSString *errorMessage = @"We ran into an error creating your user!";
        switch(error.code) {
            case FAuthenticationErrorEmailTaken:
                errorMessage = @"This email is already taken. Try Logging in?";
                break;
            case FAuthenticationErrorInvalidEmail:
                errorMessage = @"Your email wasn't in the right format. Check carefully!";
                break;
            case FAuthenticationErrorInvalidPassword:
                errorMessage = @"Your password wasn't in the right format. Check carefully!";
                break;
            case kNCUserNameValidationErrorCode:
                errorMessage = @"Your username cannot be longer than 20 characters. It can have a combination of capital and lower case letters from A-Z, numbers 0-9, and an optional underscore.";
                break;
            case kNCNameUnavailableCode:
                errorMessage = @"Someone already took this username...";
                break;
            default:
                break;
        }
        [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:errorMessage duration:2.0];
    }];
}

@end
