//
//  NCFacebookLoginViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/4/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCFacebookLoginViewController.h"
#import "NCCreateUserViewController.h"
#import "NCWorldsViewController.h"

#import "NCUserService.h"
@interface NCFacebookLoginViewController ()

@end

@implementation NCFacebookLoginViewController{
    Mixpanel *mixpanel;
}
static NSString *kLoginWithEmailAndPasswordTitle = @"Login With Email";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mixpanel = [Mixpanel sharedInstance];
    self.title = @"Welcome";
    @weakify(self);

    self.facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.facebookLoginButton.delegate = self;
    [RACObserve(self, spriteUrl) subscribeNext:^(id x) {
        @strongify(self);
        self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
        [self.spriteImageView sd_setImageWithURL:[NSURL URLWithString:x]];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"options_button"] style:UIBarButtonItemStylePlain target:self action:@selector(traditionLoginButtonDidClick:)];
    

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(spriteImageViewDidTap:)];
    [self.spriteImageView addGestureRecognizer:tapGesture];
    self.spriteImageView.userInteractionEnabled = YES;
}

-(void)spriteImageViewDidTap:(id)sender{
    NCSpritesViewController *spritesViewController = [[NCSpritesViewController alloc]init];
    spritesViewController.delegate = self;
    [self presentViewController:spritesViewController animated:YES completion:nil];
}

-(void)didSelectSpriteFromModal:(NSString *)spriteUrl{
    self.spriteUrl = [spriteUrl copy];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    NSString *loginErrorMessage = @"Looks like we ran into an issue with logging you in with Facebook. Try logging in with your email and password instead!";
    if (error) {
        [mixpanel track:@"Facebook Login Failed"];
        [[[UIAlertView alloc]initWithTitle:@"Uh Oh" message:loginErrorMessage delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:kLoginWithEmailAndPasswordTitle, nil] show];
        return;
    }
    NSString *facebookAccess = result.token.tokenString;
    @weakify(self);
    [mixpanel timeEvent:@"Facebook Login"];
    [NCLoadingView showInView:self.view];
    [[[NCUserService sharedInstance] loginWithFacebookAccessToken:facebookAccess spriteUrl:self.spriteUrl] subscribeNext:^(id x) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        [mixpanel track:@"Facebook Login"];
        NCWorldsViewController *worldsViewController = [[NCWorldsViewController alloc]init];
        [self.navigationController pushViewController:worldsViewController animated:YES];
    } error:^(NSError *error) {
        [NCLoadingView hideAllFromView:self.view];
        [mixpanel track:@"Facebook Login Failed"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh Oh" message:loginErrorMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kLoginWithEmailAndPasswordTitle, nil];
        [alert show];
    }];
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kLoginWithEmailAndPasswordTitle]) {
        [mixpanel track:@"Traditional Login Button Did Click"];
        NCCreateUserViewController *createUserViewController = [[NCCreateUserViewController alloc]init];
        createUserViewController.spriteUrl = [self.spriteUrl copy];
        [self.navigationController pushViewController:createUserViewController animated:YES];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kLoginWithEmailAndPasswordTitle]) {
        NCCreateUserViewController *createUserViewController = [[NCCreateUserViewController alloc]init];
        createUserViewController.spriteUrl = [self.spriteUrl copy];
        [self.navigationController pushViewController:createUserViewController animated:YES];
    }
}

-(void)traditionLoginButtonDidClick:(id)sender{
    [mixpanel track:@"Traditional Login Button Did Click"];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"No facebook?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kLoginWithEmailAndPasswordTitle, nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    }else{
        [actionSheet showInView:self.view];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
