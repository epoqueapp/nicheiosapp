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
#import "NCWelcomeViewController.h"
#import "Firebase+AuthenticationExtensions.h"
#import "AppDelegate.h"
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
    [self.tableView reloadData];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"options_button"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonDidClick:)];
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
    userModel.name = [form.name stringByReplacingOccurrencesOfString:@" " withString:@""];
    userModel.about = form.about;
    userModel.spriteUrl = form.spriteUrl;
    userModel.role = [NSUserDefaults standardUserDefaults].userModel.role;
    @weakify(self);
    [Amplitude logEvent:@"Update Me"];
    [NCLoadingView showInView:self.view withTitleText:@"Saving..."];
    
    NSString *userId = [NSUserDefaults standardUserDefaults].userModel.userId;
    userModel.userId = [userId copy];

    [[[[[Firebase alloc]initWithUrl:kFirebaseRoot] rac_validateName:form.name] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self updateUserWithModel:userModel];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        [Amplitude logEvent:@"Update Me"];
        [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Saved your information successfully! Thank you" duration:2.0];
        [successSoundEffect play];
    } error:^(NSError *error) {
        @strongify(self);
        [errorSoundEffect play];
        [NCLoadingView hideAllFromView:self.view];
        
        NSString *errorMessage = @"We ran into an issue saving your info";
        if (error.code == kNCUserNameValidationErrorCode) {
            errorMessage = @"Your username cannot be longer than 20 characters. It can have a combination of capital and lower case letters from A-Z, numbers 0-9, and an optional underscore.";
        }
        if (error.code == kNCNameUnavailableCode) {
            errorMessage = @"Someone already took this username...";
        }
        
        [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:errorMessage duration:2.0];
    }];
}

-(RACSignal *)updateUserWithModel:(UserModel *)userModelToUpdate{
    NSDictionary *dictionary = [userModel toDictionary];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[fireService.usersRef childByAppendingPath:userModelToUpdate.userId] updateChildValues:dictionary withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                [subscriber sendError:error];
            }else{
                [subscriber sendNext:ref];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

-(void)optionsButtonDidClick:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) logout];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
