//
//  NCWorldDetailViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldsViewController.h"
#import "NCEditWorldViewController.h"
#import "NCNavigationController.h"
#import "NCWorldDetailViewController.h"
#import "NCInviteUsersViewController.h"
#import "NCWorldChatViewController.h"
#import "NCFireService.h"
#import "NCWorldService.h"
#import "NCUsersViewController.h"
#import "WorldModel.h"
@interface NCWorldDetailViewController ()

@end

@implementation NCWorldDetailViewController{
    NCFireService *fireService;
    NCWorldService *worldService;
    Mixpanel *mixpanel;
}

static NSString* const kRequestToJoinTitle = @"Request to Join";
static NSString* const kJoinWorldTitle = @"Join this World";
static NSString* const kEnterWorldTitle = @"Enter World";
static NSString* const kDeleteWorldTitle = @"Delete World";
static NSString* const kEditWorldTitle = @"Edit World";
static NSString* const kLeaveWorldTitle = @"Leave World";
static NSString* const kViewMembers = @"View Members";
static NSString* const kTurnOnPush = @"Turn On Notifications";
static NSString* const kTurnOffPush = @"Turn Off Notifications";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton];
    fireService = [NCFireService sharedInstance];
    worldService = [NCWorldService sharedInstance];
    mixpanel = [Mixpanel sharedInstance];
    
    UIBarButtonItem *optionBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"options_button"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonDidClick:)];
    self.navigationItem.rightBarButtonItem = optionBarButtonItem;
    
    @weakify(self);
    
    [NCLoadingView showInView:self.view];
    self.view.alpha = 0;
    RAC(self, worldModel) = [[[[RACObserve(self, worldId) flattenMap:^RACStream *(id value) {
        return [worldService getWorldById:value];
    }] retry:0] doNext:^(id x) {
        @strongify(self);
        [UIView animateWithDuration:0.10 animations:^{
            self.view.alpha = 1;
        }];
        [NCLoadingView hideAllFromView:self.view];
    }] doError:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
    }];
    
    [RACObserve(self, worldModel)
     subscribeNext:^(WorldModel *worldModel) {
        @strongify(self);
        [self.emblemImageView sd_setImageWithURL:[NSURL URLWithString:worldModel.imageUrl]];
        self.emblemImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.nameLabel.text = worldModel.name;
        self.title = worldModel.name;
        self.detailTextView.text = worldModel.detail;
        self.view.backgroundColor = [UIColor blackColor];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.detailTextView.backgroundColor = [UIColor blackColor];
        self.detailTextView.textColor = [UIColor whiteColor];
        
        if (worldModel.isPrivate) {
            [self.requestToJoinButton setTitle:kRequestToJoinTitle forState:UIControlStateNormal];
            self.worldTypeImageView.image = [UIImage imageNamed:@"key_icon"];
            self.worldTypeLabel.text = @"Private World";
        }
        else
        {
            [self.requestToJoinButton setTitle:kJoinWorldTitle forState:UIControlStateNormal];
        }
        
        if (worldModel.isDefault) {
            self.worldTypeImageView.image = [UIImage imageNamed:@"saturn_icon"];
            self.worldTypeLabel.text = @"Public Default World";
        }
        
        if (!worldModel.isDefault && !worldModel.isPrivate) {
            self.worldTypeLabel.text = @"Public World";
        }
        
        NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
        if ([worldModel.memberUserIds containsObject:myUserId] || [worldModel.moderatorUserIds containsObject:myUserId]) {
            [self.requestToJoinButton setTitle:kViewMembers forState:UIControlStateNormal];
            self.inviteUsersButton.hidden = NO;
        }else{
            self.inviteUsersButton.hidden = YES;
        }
    } error:^(NSError *error) {
        
    }];
    
    self.emblemImageView.layer.cornerRadius = 3.0;
    self.emblemImageView.layer.masksToBounds = YES;
    self.emblemImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.emblemImageView.layer.borderWidth = 1.0;
    
    self.requestToJoinButton.layer.cornerRadius = 3.0;
    self.requestToJoinButton.layer.masksToBounds = YES;
    self.requestToJoinButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.requestToJoinButton.layer.borderWidth = 1.0;
    
    self.inviteUsersButton.layer.cornerRadius = 3.0;
    self.inviteUsersButton.layer.masksToBounds = YES;
    self.inviteUsersButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.inviteUsersButton.layer.borderWidth = 1.0;
    
    self.toggleNotificationButton.layer.cornerRadius = 3.0;
    self.toggleNotificationButton.layer.masksToBounds = YES;
    self.toggleNotificationButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.toggleNotificationButton.layer.borderWidth = 1.0;
    
    [self.requestToJoinButton addTarget:self action:@selector(mainButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.inviteUsersButton addTarget:self action:@selector(inviteUsersButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.toggleNotificationButton addTarget:self action:@selector(toggleNotificationButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [[fireService worldPushSettings:self.worldId userId:[NSUserDefaults standardUserDefaults].userModel.userId] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        if (snapshot.value == [NSNull null]) {
            self.isPushOn = NO;
        }else{
            self.isPushOn = [snapshot.value boolValue];
        }
    }];
    
    [RACObserve(self, isPushOn) subscribeNext:^(id x) {
        @strongify(self);
        BOOL isPushOn = [x boolValue];
        if(isPushOn){
            [self.toggleNotificationButton setTitle:kTurnOffPush forState:UIControlStateNormal];
            self.toggleNotificationButton.backgroundColor = [UIColor darkGrayColor];
        }else{
            
            [self.toggleNotificationButton setTitle:kTurnOnPush forState:UIControlStateNormal];
            self.toggleNotificationButton.backgroundColor = [UIColor colorWithRed:11.0/255.0 green:156.0/255.0 blue:143.0/255.0 alpha:1.0];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)toggleNotificationButtonDidClick:(id)sender{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    if (self.isPushOn) {
        [mixpanel track:@"Turned Off World Notifications" properties:@{@"worldId": self.worldId}];
        [CSNotificationView showInViewController:self tintColor:[UIColor darkGrayColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Turned OFF world notifications" duration:2.0];
        [[fireService worldPushSettings:self.worldId userId:myUserId] setValue:@(NO)];
    }else{
        [mixpanel track:@"Turned On World Notifications" properties:@{@"worldId": self.worldId}];
         [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Turned ON world notifications" duration:2.0];
        [[fireService worldPushSettings:self.worldId userId:myUserId] setValue:@(YES)];
    }
}

-(void)optionsButtonDidClick:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]init];
    UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
    if (self.worldModel == nil) {
        return;
    }
    if ([self.worldModel.moderatorUserIds containsObject:userModel.userId] || [userModel.role isEqualToString:@"admin"]) {
        [actionSheet addButtonWithTitle:kEditWorldTitle];
        [actionSheet addButtonWithTitle:kDeleteWorldTitle];
    }
    if ([self.worldModel.moderatorUserIds containsObject:userModel.userId] || [self.worldModel.memberUserIds containsObject:userModel.userId]) {
        [actionSheet addButtonWithTitle:kLeaveWorldTitle];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kLeaveWorldTitle]) {
        [mixpanel track:@"Leave World Button Did Click" properties:@{@"worldId": self.worldId}];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"Are you sure you want to leave this world?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kLeaveWorldTitle, nil];
        [alertView show];
    }
    
    if ([title isEqualToString:kDeleteWorldTitle]) {
        [mixpanel track:@"Delete World Button Did Click" properties:@{@"worldId": self.worldId}];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"Are you sure you want to delete this world?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kDeleteWorldTitle, nil];
        [alertView show];
    }
    
    if ([title isEqualToString:kEditWorldTitle]) {
        [mixpanel track:@"Edit World Button Did Click" properties:@{@"worldId": self.worldId}];
        [self goToWorldEdit];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kDeleteWorldTitle]) {
        [mixpanel track:@"Confirm Delete World Button Did Click" properties:@{@"worldId": self.worldId}];
        [[worldService deleteWorldWithId:self.worldId] subscribeNext:^(id x) {
            
        }];
        [self.navigationController goToWorldsController];
    }
    if ([title isEqualToString:kLeaveWorldTitle]) {
        [mixpanel track:@"Confirm Leave World Button Did Click" properties:@{@"worldId": self.worldId}];
        [[worldService unjoinWorldById:self.worldId] subscribeNext:^(id x) {
        }];
        [self.navigationController goToWorldsController];
    }
}

-(void)inviteUsersButtonDidClick:(id)sender{
    [mixpanel track:@"Invite Users Button Did Click" properties:@{@"worldId": self.worldId}];
    NCInviteUsersViewController *inviteUsers = [[NCInviteUsersViewController alloc]init];
    inviteUsers.worldId = [self.worldId copy];
    NCNavigationController *navController = [[NCNavigationController alloc]initWithRootViewController:inviteUsers];
    [self presentViewController:navController animated:YES completion:nil];
}


-(void)mainButtonDidClick:(id)sender{
    if ([self.requestToJoinButton.titleLabel.text isEqualToString:kJoinWorldTitle]) {
        [mixpanel track:@"Join World Button Did Click" properties:@{@"worldId": self.worldId}];
        [NCLoadingView showInView:self.view];
        @weakify(self);
        [[worldService joinWorldById:self.worldId] subscribeNext:^(WorldModel *worldModel) {
            @strongify(self);
            self.worldModel = worldModel;
        } error:^(NSError *error) {
            @strongify(self);
            [NCLoadingView hideAllFromView:self.view];
        } completed:^{
            @strongify(self);
            [NCLoadingView hideAllFromView:self.view];
            [self goToChat];
        }];
    }
    if ([self.requestToJoinButton.titleLabel.text  isEqualToString:kEnterWorldTitle]) {
        [mixpanel track:@"Enter World Button Did Click" properties:@{@"worldId": self.worldId}];
        [self goToChat];
    }
    if ([self.requestToJoinButton.titleLabel.text isEqualToString:kViewMembers]) {
        [mixpanel track:@"View World Members Button Did Click" properties:@{@"worldId": self.worldId}];
        [self goToMembers];
    }
}

-(void)goToChat{
    NCWorldChatViewController *chatViewController = [[NCWorldChatViewController alloc]init];
    chatViewController.worldId = [self.worldId copy];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

-(void)goToMembers{
    NCUsersViewController *usersViewController = [[NCUsersViewController alloc]init];
    usersViewController.worldModel = self.worldModel;
    [self.navigationController pushViewController:usersViewController animated:YES];
}

-(void)goToWorldEdit{
    UserModel *myUserModel = [NSUserDefaults standardUserDefaults].userModel;
    [mixpanel track:@"Edit World Button Did Click" properties:@{@"worldId": self.worldId}];
    NCEditWorldViewController *editWorldViewController = [[NCEditWorldViewController alloc]init];
    editWorldViewController.worldModel = self.worldModel;
    [self.navigationController pushRetroViewController:editWorldViewController];
}

@end
