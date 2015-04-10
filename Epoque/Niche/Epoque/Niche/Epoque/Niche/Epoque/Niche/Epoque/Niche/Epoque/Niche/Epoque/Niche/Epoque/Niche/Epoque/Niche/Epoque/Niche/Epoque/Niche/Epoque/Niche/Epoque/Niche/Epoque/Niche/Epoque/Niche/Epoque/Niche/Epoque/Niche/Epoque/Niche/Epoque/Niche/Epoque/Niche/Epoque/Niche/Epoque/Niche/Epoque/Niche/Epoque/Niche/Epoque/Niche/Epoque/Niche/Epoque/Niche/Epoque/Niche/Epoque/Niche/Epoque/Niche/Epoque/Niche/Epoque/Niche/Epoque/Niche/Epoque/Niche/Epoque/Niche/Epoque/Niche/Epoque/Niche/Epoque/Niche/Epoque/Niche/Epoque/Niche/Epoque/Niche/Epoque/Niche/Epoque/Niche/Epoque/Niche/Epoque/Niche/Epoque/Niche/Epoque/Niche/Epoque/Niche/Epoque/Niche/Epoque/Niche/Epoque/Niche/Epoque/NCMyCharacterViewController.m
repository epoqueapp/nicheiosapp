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
    Mixpanel *mixpanel;
    NCSoundEffect *successSoundEffect;
    NCSoundEffect *errorSoundEffect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MY CHARACTER";
    
    successSoundEffect = [[NCSoundEffect alloc]initWithSoundNamed:@"success.wav"];
    errorSoundEffect = [[NCSoundEffect alloc]initWithSoundNamed:@"error.wav"];
    
    mixpanel = [Mixpanel sharedInstance];
    
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
    form.obscurity = [NSUserDefaults standardUserDefaults].obscurity;
    [self.tableView reloadData];
}

-(void)spriteDidTap{
    [mixpanel timeEvent:@"Sprite Did Tap"];
    NCSpritesViewController *spritesViewController = [[NCSpritesViewController alloc]init];
    spritesViewController.delegate = self;
    [self presentViewController:spritesViewController animated:YES completion:nil];
}

-(void)didSelectSpriteFromModal:(NSString *)spriteUrl{
    [mixpanel timeEvent:@"Changed My Sprite"];
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
    
    [[NSUserDefaults standardUserDefaults]setObscurity:form.obscurity];
    
    @weakify(self);
    [mixpanel timeEvent:@"Update Me"];
    [NCLoadingView showInView:self.view withTitleText:@"Saving..."];
    [[userService updateMe:userModel]subscribeNext:^(id x) {
        @strongify(self);
        [successSoundEffect play];
        [NCLoadingView hideAllFromView:self.view];
        [mixpanel track:@"Update Me"];
        [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Save your information successfully! Thank you" duration:2.0];
    }error:^(NSError *error) {
        @strongify(self);
        [errorSoundEffect play];
        [NCLoadingView hideAllFromView:self.view];
        [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:12.0] textAlignment:NSTextAlignmentLeft image:nil message:@"We ran into an issue saving your info" duration:2.0];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
