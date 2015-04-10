//
//  NCCreateUserViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/19/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCCreateUserViewController.h"
#import "NCLoginViewController.h"
#import "NCWorldsViewController.h"
#import "NCCreateUserForm.h"
#import "NCFireService.h"
#import "NCUserService.h"
#import "NCUploadService.h"
@interface NCCreateUserViewController ()

@end

@implementation NCCreateUserViewController{
    NCFireService *fireService;
    NCUserService *userService;
    NCUploadService *uploadService;
    Mixpanel *mixpanel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fireService = [NCFireService sharedInstance];
    uploadService = [NCUploadService sharedInstance];
    userService = [NCUserService sharedInstance];
    
    mixpanel = [Mixpanel sharedInstance];
    
    [self setUpBackButton];
    self.title = @"Create User";
    
    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.tableView;
    self.formController.delegate = self;
    self.formController.form = [[NCCreateUserForm alloc] init];
    self.tableView.scrollEnabled = NO;
    
    @weakify(self);
    [RACObserve(self, spriteUrl) subscribeNext:^(id x) {
        @strongify(self);
        self.spriteImageView.layer.magnificationFilter = kCAFilterNearest;
        [self.spriteImageView sd_setImageWithURL:[NSURL URLWithString:x]];
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
    self.spriteImageView.userInteractionEnabled = YES;
    [self.spriteImageView addGestureRecognizer:tapGesture];
    [tapGesture.rac_gestureSignal subscribeNext:^(id x) {
        @strongify(self);
        NCSpritesViewController *spritesViewController = [[NCSpritesViewController alloc]init];
        spritesViewController.delegate = self;
        [self presentViewController:spritesViewController animated:YES completion:nil];
    }];
    
    RAC(self, spriteUrl) = [[self rac_signalForSelector:@selector(didSelectSpriteFromModal:) fromProtocol:@protocol(NCSpritesViewControllerDelegate)] map:^id(RACTuple *tuple) {
        [mixpanel track:@"Changed Sprite" properties:@{@"spriteUrl": tuple.first}];
        return [tuple.first copy];
    }];
    
    self.createButton.layer.cornerRadius = 3.0f;
    
    RACCommand *createButtonCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [mixpanel track:@"Create User Button Did Click"];
        NCCreateUserForm *form = self.formController.form;
        NSString *email = form.email;
        NSString *password = form.password;
        NSString *name = form.name;
        [mixpanel timeEvent:@"Create User"];
        [[userService signupWithEmail:email password:password name:name about:@"" spriteUrl:self.spriteUrl imageUrl:@""] subscribeNext:^(id x) {
            [mixpanel track:@"Create User"];
            NCWorldsViewController *worldViewController = [[NCWorldsViewController alloc]init];
            [self.navigationController pushViewController:worldViewController animated:YES];
        } error:^(NSError *error) {
            [mixpanel track:@"Create User"];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Uh oh" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alertView show];
        }];
        return [RACSignal empty];
    }];
    self.createButton.rac_command = createButtonCommand;
    self.loginButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [mixpanel track:@"Login With Email and Password Button Did Click"];
        NCLoginViewController *loginViewController = [[NCLoginViewController alloc]init];
        [self.navigationController pushViewController:loginViewController animated:YES];
        return [RACSignal empty];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
