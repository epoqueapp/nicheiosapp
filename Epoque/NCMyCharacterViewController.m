//
//  NCMyCharacterViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/20/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//
#import <RESideMenu/RESideMenu.h>
#import "NCMyCharacterViewController.h"
#import "NCMyCharacterForm.h"
#import "NCFireService.h"
#import "NCUserService.h"
#import "NCSpritesViewController.h"
@interface NCMyCharacterViewController ()

@end

@implementation NCMyCharacterViewController{
    NCFireService *fireService;
    NCUserService *userService;
    UserModel *userModel;
    NCSoundEffect *successSoundEffect;
    NCSoundEffect *errorSoundEffect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MY CHARACTER";
    
    successSoundEffect = [[NCSoundEffect alloc]initWithSoundNamed:@"success.wav"];
    errorSoundEffect = [[NCSoundEffect alloc]initWithSoundNamed:@"error.wav"];
    
    fireService = [NCFireService sharedInstance];
    
    [self setUpMenuButton];
    NCMyCharacterForm *form = [[NCMyCharacterForm alloc]init];
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.tableView;
    self.formController.delegate = self;
    self.formController.form = form;
    self.tableView.separatorColor = [UIColor clearColor];
    userService = [NCUserService sharedInstance];
    userModel = [NSUserDefaults standardUserDefaults].userModel;
    form.spriteUrl = userModel.spriteUrl;
    form.name = userModel.name;
    form.about = userModel.about;
    form.isObscuring = [[NSUserDefaults standardUserDefaults] isObscuring];
    [self.tableView reloadData];
}

-(void)spriteDidTap{
    [Amplitude logEvent:@"Sprite Did Tap"];
    NCSpritesViewController *spritesViewController = [[NCSpritesViewController alloc]init];
    spritesViewController.delegate = self;
    [self presentViewController:spritesViewController animated:YES completion:nil];
}

-(void)didSelectSpriteFromModal:(NSString *)spriteUrl{
    [Amplitude logEvent:@"Changed My Sprite"];
    NCMyCharacterForm *form =  (NCMyCharacterForm *)self.formController.form;
    form.spriteUrl = [spriteUrl copy];
    [self.tableView reloadData];
}

-(void)submitButtonDidTap{
    NCMyCharacterForm *form = (NCMyCharacterForm *)self.formController.form;
    userModel.name = form.name;
    userModel.about = form.about;
    userModel.spriteUrl = form.spriteUrl;
    userModel.imageUrl = @"";
    userModel.role = [NSUserDefaults standardUserDefaults].userModel.role;
    
    [[NSUserDefaults standardUserDefaults] setIsObscuring:form.isObscuring];
    
    @weakify(self);
    [Amplitude logEvent:@"Update Me"];
    [NCLoadingView showInView:self.view withTitleText:@"Saving..."];
    
    
    NSString *userId = [NSUserDefaults standardUserDefaults].userModel.userId;
    NSDictionary *dictionary = [userModel toDictionary];
    [[fireService.usersRef childByAppendingPath:userId] updateChildValues:dictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
        @strongify(self);
        if (error) {
            [errorSoundEffect play];
            [NCLoadingView hideAllFromView:self.view];
            [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"We ran into an issue saving your info" duration:2.0];
        }else{
            [successSoundEffect play];
            [NCLoadingView hideAllFromView:self.view];
            [Amplitude logEvent:@"Update Me"];
            [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Saved your information successfully! Thank you" duration:2.0];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
