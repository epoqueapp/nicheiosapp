//
//  NCWorldDetailViewController.m
//  Niche
//
//  Created by Maximilian Alexander on 3/24/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCWorldsViewController.h"
#import "NCWorldDetailViewController.h"
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
}

static NSString* const kRequestToJoinTitle = @"Request to Join";
static NSString* const kJoinWorldTitle = @"Join this World";
static NSString* const kEnterWorldTitle = @"Enter World";
static NSString* const kDeleteWorldTitle = @"Delete World";
static NSString* const kLeaveWorldTitle = @"Leave World";
static NSString* const kViewMembers = @"View Members";
static NSString* const kTurnOnPush = @"Turn On Notifications";
static NSString* const kTurnOffPush = @"Turn Off Notifications";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton];
    fireService = [NCFireService sharedInstance];
    worldService = [NCWorldService sharedInstance];
    
    UIBarButtonItem *optionBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"options_button"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonDidClick:)];
    self.navigationItem.rightBarButtonItem = optionBarButtonItem;
    
    @weakify(self);
    [RACObserve(self, world) subscribeNext:^(WorldModel *worldModel) {
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
    
    [[fireService worldPushSettings:self.world.worldId userId:[NSUserDefaults standardUserDefaults].userModel.userId] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"World Push Settings Changed:%@",snapshot.value);
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
        [CSNotificationView showInViewController:self tintColor:[UIColor darkGrayColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Turned OFF world notifications" duration:2.0];
        [[fireService worldPushSettings:self.world.worldId userId:myUserId] setValue:@(NO)];
    }else{
         [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Turned ON world notifications" duration:2.0];
        [[fireService worldPushSettings:self.world.worldId userId:myUserId] setValue:@(YES)];
    }
}

-(void)optionsButtonDidClick:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]init];
    UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
    if ([self.world.moderatorUserIds containsObject:userModel.userId]) {
        [actionSheet addButtonWithTitle:@"Delete World"];
    }
    if ([self.world.moderatorUserIds containsObject:userModel.userId] || [self.world.memberUserIds containsObject:userModel.userId]) {
        [actionSheet addButtonWithTitle:@"Leave World"];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kLeaveWorldTitle]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"Are you sure you want to leave this world?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kLeaveWorldTitle, nil];
        [alertView show];
    }
    
    if ([title isEqualToString:kDeleteWorldTitle]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"Are you sure you want to delete this world?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kDeleteWorldTitle, nil];
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kDeleteWorldTitle]) {
        @weakify(self);
        [[worldService deleteWorldWithId:self.world.worldId] subscribeNext:^(id x) {
            @strongify(self);
            NCWorldsViewController *worldsViewController = [[NCWorldsViewController alloc]init];
            [self.navigationController pushViewController:worldsViewController animated:YES];
        }];
    }
    if ([title isEqualToString:kLeaveWorldTitle]) {
        @weakify(self);
        [[worldService unjoinWorldById:self.world.worldId] subscribeNext:^(id x) {
            @strongify(self);
            NCWorldsViewController *worldsViewController = [[NCWorldsViewController alloc]init];
            [self.navigationController pushViewController:worldsViewController animated:YES];
        }];
    }
}

-(void)inviteUsersButtonDidClick:(id)sender{
    
}


-(void)mainButtonDidClick:(id)sender{
    if ([self.requestToJoinButton.titleLabel.text  isEqualToString:kJoinWorldTitle]) {
        [NCLoadingView showInView:self.view];
        @weakify(self);
        [[worldService joinWorldById:self.world.worldId] subscribeNext:^(WorldModel *worldModel) {
            @strongify(self);
            self.world = worldModel;
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
        [self goToChat];
    }
    if ([self.requestToJoinButton.titleLabel.text isEqualToString:kViewMembers]) {
        [self goToMembers];
    }
}

-(void)goToChat{
    NCWorldChatViewController *chatViewController = [[NCWorldChatViewController alloc]init];
    chatViewController.worldModel = self.world;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

-(void)goToMembers{
    NCUsersViewController *usersViewController = [[NCUsersViewController alloc]init];
    usersViewController.worldModel = self.world;
    [self.navigationController pushViewController:usersViewController animated:YES];
}

-(void)goToWorldEdit{
    
}

@end
