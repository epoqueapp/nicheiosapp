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
#import "NCWorldChatViewController.h"
#import "NCUsersTableViewController.h"
#import "NCFireService.h"
#import "WorldModel.h"
#import "NCShareWorldView.h"
@interface NCWorldDetailViewController ()

@end

@implementation NCWorldDetailViewController{
    NCFireService *fireService;
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
static NSString* const kRefreshPasscode = @"Refresh";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton];
    fireService = [NCFireService sharedInstance];
    
    UIBarButtonItem *optionBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"options_button"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonDidClick:)];
    self.navigationItem.rightBarButtonItem = optionBarButtonItem;
    
    @weakify(self);
    [[fireService.worldsRef childByAppendingPath:self.worldId] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        WorldModel *worldModel = [[WorldModel alloc]initWithSnapshot:snapshot];
        self.worldModel = [worldModel copy];
        
        if (worldModel == nil || [worldModel isEqual:[NSNull null]]) {
            return ;
        }
        
        [self.emblemImageView sd_setImageWithURL:[NSURL URLWithString:worldModel.imageUrl]];
        self.emblemImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.nameLabel.text = worldModel.name;
        self.title = worldModel.name;
        self.detailTextView.text = worldModel.detail;
        self.view.backgroundColor = [UIColor blackColor];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.detailTextView.backgroundColor = [UIColor clearColor];
        self.detailTextView.textColor = [UIColor whiteColor];
        
        NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
        NSString *myRole = [NSUserDefaults standardUserDefaults].userModel.role;
        self.isFavorite = [self.worldModel.favoritedUserIds containsObject:myUserId];
        
        self.keyImageView.hidden = !worldModel.isPrivate;
        self.pinLabel.hidden = !worldModel.isPrivate;
        self.pinLabel.text = worldModel.passcode;

        BOOL isModerator = [self.worldModel.moderatorUserIds containsObject:myUserId] || [myRole isEqualToString:@"admin"];
        
        if(worldModel.isPrivate){
            if (isModerator) {
                self.refreshPasscodeButton.hidden = NO;
            }else{
                self.refreshPasscodeButton.hidden = YES;
            }
        }else{
            self.refreshPasscodeButton.hidden = YES;
        }
    }];
    self.emblemImageView.layer.cornerRadius = 3.0;
    self.emblemImageView.layer.masksToBounds = YES;
    self.emblemImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.emblemImageView.layer.borderWidth = 1.0;
    
    self.notificationButton.layer.cornerRadius = self.notificationButton.frame.size.height / 2;
    self.notificationButton.backgroundColor = [UIColor colorWithHexString:@"#004358"];
    [self.notificationButton addTarget:self action:@selector(notificationButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareButton.layer.cornerRadius = self.shareButton.frame.size.height / 2;
    self.shareButton.backgroundColor = [UIColor colorWithHexString:@"#1F8A70"];
    [self.shareButton addTarget:self action:@selector(shareButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.favoriteButton.layer.cornerRadius = self.favoriteButton.frame.size.height / 2;
    self.favoriteButton.backgroundColor = [UIColor colorWithHexString:@"#FD7400"];
    [self.favoriteButton addTarget:self action:@selector(favoriteButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.refreshPasscodeButton addTarget:self action:@selector(refreshPasscodeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [RACObserve(self, isFavorite) subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue]) {
            self.favoriteButton.backgroundColor = [UIColor colorWithHexString:@"#FD7400"];
            [self.favoriteButton setImage:[UIImage imageNamed:@"star_icon_full_large"] forState:UIControlStateNormal];
        }else{
            self.favoriteButton.backgroundColor = [UIColor darkGrayColor];
            [self.favoriteButton setImage:[UIImage imageNamed:@"star_icon_hollow_large"] forState:UIControlStateNormal];
        }
    }];
    
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    [[[[fireService.rootRef childByAppendingPath:@"worlds-user-push-settings"] childByAppendingPath:self.worldId] childByAppendingPath:myUserId] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        if (snapshot.value == [NSNull null] || [snapshot.value boolValue] == NO) {
            self.isPushOn = NO;
        }else{
            self.isPushOn = YES;
        }
    }];
    
    [RACObserve(self, isPushOn) subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue]) {
            self.notificationButton.backgroundColor = [UIColor colorWithHexString:@"#3498DB"];
            [self.notificationButton setImage:[UIImage imageNamed:@"bell_ring_icon"] forState:UIControlStateNormal];
        }else{
            self.notificationButton.backgroundColor = [UIColor darkGrayColor];
            [self.notificationButton setImage:[UIImage imageNamed:@"bell_no_ring_icon"] forState:UIControlStateNormal];            
        }
    }];
}

-(void)favoriteButtonDidClick:(id)sender{
    self.isFavorite = !self.isFavorite;
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    NSMutableArray *favoritedUserIds = [self.worldModel.favoritedUserIds mutableCopy];
    if (self.isFavorite) {
        if (![favoritedUserIds containsObject:myUserId]) {
            [favoritedUserIds addObject:myUserId];
        }
        [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"You favorited this world" duration:2.0];
    }else{
        [favoritedUserIds removeObject:myUserId];
    }
    [[[fireService.worldsRef childByAppendingPath:self.worldId] childByAppendingPath:@"favoritedUserIds"] setValue:favoritedUserIds];
}

-(void)shareButtonDidClick:(id)sender{
    NSString *string = [NSString stringWithFormat:@"I want you to join this world on Epoque."];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/epoque-a-living-world-atlas/id918925175"]];
    NCShareWorldView *shareWorld = [NCShareWorldView generateView];
    shareWorld.worldImageView.image = self.emblemImageView.image;
    shareWorld.worldNameLabel.text = self.worldModel.name;
    
    
    if (self.worldModel.isPrivate) {
        [shareWorld setPINWithString:self.worldModel.passcode];
    }
    
    UIImage *image = [shareWorld toImage];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:@[string, url, image] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

-(void)notificationButtonDidClick:(id)sender{
    self.isPushOn = !self.isPushOn;
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    if (self.isPushOn) {
                                            [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"You turned on notification for this world." duration:2.0];
        [[[[fireService.rootRef childByAppendingPath:@"worlds-user-push-settings"] childByAppendingPath:self.worldId] childByAppendingPath:myUserId] setValue:@(YES)];
    }else{
        [[[[fireService.rootRef childByAppendingPath:@"worlds-user-push-settings"] childByAppendingPath:self.worldId] childByAppendingPath:myUserId] removeValue];
    }
}

-(void)refreshPasscodeButtonDidClick:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Refresh the Passcode?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kRefreshPasscode, nil];
    [alert show];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)optionsButtonDidClick:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]init];
    UserModel *userModel = [NSUserDefaults standardUserDefaults].userModel;
    [actionSheet addButtonWithTitle:kViewMembers];
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
        [Amplitude logEvent:@"Leave World Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"Are you sure you want to leave this world?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kLeaveWorldTitle, nil];
        [alertView show];
    }
    
    if ([title isEqualToString:kDeleteWorldTitle]) {
        [Amplitude logEvent:@"Delete World Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:@"Are you sure you want to delete this world?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kDeleteWorldTitle, nil];
        [alertView show];
    }
    
    if ([title isEqualToString:kEditWorldTitle]) {
        [Amplitude logEvent:@"Edit World Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
        [self goToWorldEdit];
    }
    
    if ([title isEqualToString:kViewMembers]) {
        [Amplitude logEvent:@"View Members Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
        [self gotToViewMembers];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kDeleteWorldTitle]) {
        [Amplitude logEvent:@"Confirm Delete World Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
        [[fireService deleteWorld:self.worldId] subscribeNext:^(id x) {
            [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Successfully deleted your world!" duration:2.0];
        } error:^(NSError *error) {
            [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"We ran into an issue deleting this world..." duration:2.0];
        }];
        [self.navigationController goToWorldsController];
    }
    if ([title isEqualToString:kLeaveWorldTitle]) {
        [Amplitude logEvent:@"Confirm Leave World Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
        // TODO:
        [self.navigationController goToWorldsController];
    }
    if ([title isEqualToString:kRefreshPasscode]) {
        [[[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"worlds"]childByAppendingPath:self.worldId] childByAppendingPath:@"passcode"] setValue:[NSString generateRandomPIN:4]];
    }
}

-(void)goToChat{
    NCWorldChatViewController *chatViewController = [[NCWorldChatViewController alloc]init];
    chatViewController.worldId = [self.worldId copy];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

-(void)goToWorldEdit{
    UserModel *myUserModel = [NSUserDefaults standardUserDefaults].userModel;
    if ([self.worldModel.moderatorUserIds containsObject:myUserModel.userId] || [myUserModel.role isEqualToString:@"admin"]) {
        [Amplitude logEvent:@"Edit World Button Did Click" withEventProperties:@{@"worldId": self.worldId}];
        NCEditWorldViewController *editWorldViewController = [[NCEditWorldViewController alloc]init];
        editWorldViewController.worldId = self.worldModel.worldId;
        [self.navigationController pushRetroViewController:editWorldViewController];
    }
}

-(void)gotToViewMembers{
    NCUsersTableViewController *usersViewController = [[NCUsersTableViewController alloc]init];
    usersViewController.worldId = [self.worldId copy];
    [self.navigationController pushRetroViewController:usersViewController];
}

@end
