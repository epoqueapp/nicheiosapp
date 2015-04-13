//
//  NCInviteUsersViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//
#import "NCUserService.h"
#import "NCUserTableViewCell.h"
#import "NCInviteUsersViewController.h"
#import "NCFireService.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@interface NCInviteUsersViewController ()

@end

@implementation NCInviteUsersViewController{
    NSArray *users;
    NCUserService *userService;
    NSString *selectedUserId;
}

static NSString *UserCellIdentifier = @"UserCellIdentifier";
static NSString *kAddAsMember = @"Add As Member";
static NSString *kAddAsModerator = @"Add As Moderator";
static NSString *kCancel = @"Cancel";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.worldName;
    [self setUpBackButton];
    users = [NSArray array];
    userService = [NCUserService sharedInstance];
    @weakify(self);
    [[[[NCFireService sharedInstance] worldsRef] childByAppendingPath:self.worldId] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        @strongify(self);
        if (snapshot.value != [NSNull null]) {
            NSString *worldName = [snapshot.value objectForKey:@"name"];
            self.title = [NSString stringWithFormat:@"Add Users: %@", worldName];
        }
    }];

    [self.tableView registerNib:[UINib nibWithNibName:@"NCUserTableViewCell" bundle:nil] forCellReuseIdentifier:UserCellIdentifier];
    
    self.tableView.rowHeight = 72.0;
    
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonDidClick:)];
    
    
    [[[[[[self rac_signalForSelector:@selector(searchBar:textDidChange:) fromProtocol:@protocol(UISearchBarDelegate)] map:^id(RACTuple *tuple) {
        NSString *searchText = tuple.second;
        return searchText;
    }] throttle:0.5] doNext:^(id x) {
        @strongify(self);
        [NCLoadingView showInView:self.view];
    }] flattenMap:^RACStream *(NSString *searchTerm) {
        return [userService getInviteAbleUsersForWorldId:self.worldId searchTerm:searchTerm];
    }] subscribeNext:^(NSArray *retrievedUsers) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        users = retrievedUsers;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        [NCLoadingView hideAllFromView:self.view];
        NSLog(@"Error getting %@", error);
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCUserTableViewCell *userTableViewCell = [tableView dequeueReusableCellWithIdentifier:UserCellIdentifier];
    UserModel *userModel = [users objectAtIndex:indexPath.row];
    
    userTableViewCell.spriteImageView.transform = CGAffineTransformMakeScale(0, 0);
    userTableViewCell.spriteImageView.alpha = 0;
    [userTableViewCell.spriteImageView sd_setImageWithURL:[NSURL URLWithString:userModel.spriteUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error == nil) {
            userTableViewCell.spriteImageView.transform = CGAffineTransformIdentity;
            userTableViewCell.spriteImageView.alpha = 1;
        }
    }];
    userTableViewCell.roleLabel.hidden = YES;
    userTableViewCell.nameLabel.text = userModel.name;
    userTableViewCell.aboutLabel.text = userModel.about;
    return userTableViewCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserModel *userModel = [users objectAtIndex:indexPath.row];
    selectedUserId = [userModel.userId copy];
    NSString *message = [NSString stringWithFormat:@"Add %@", userModel.name];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:kCancel otherButtonTitles:kAddAsMember, kAddAsModerator, nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kCancel]) {
        return;
    }
    NSString *worldId = self.worldId;
    BOOL isModerator = NO;
    if ([title isEqualToString:kAddAsModerator]) {
        isModerator = YES;
    }
    @weakify(self);
    [[userService addUserToWorldId:worldId userId:selectedUserId isModerator:isModerator] subscribeNext:^(id x) {
        @strongify(self);
        [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Added! Thanks" duration:2.0];
        self.searchBar.text = @"";
        
    } error:^(NSError *error) {
        @strongify(self);
        [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Uh Oh! We ran into an issue adding" duration:2.0];
    }];
}

-(void)dismissButtonDidClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
