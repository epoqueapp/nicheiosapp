//
//  NCUsersViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 3/31/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCUsersViewController.h"
#import "NCPrivateChatViewController.h"
#import "NCUserService.h"
#import "NCUserTableViewCell.h"
@interface NCUsersViewController ()

@end

@implementation NCUsersViewController{
    NSMutableArray *users;
    NCUserService *userService;
}
static NSString *CellIdentifier = @"CellIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton];
    userService = [NCUserService sharedInstance];
    self.title = @"Users";
    users = [NSMutableArray array];
    [self.tableView registerNib:[UINib nibWithNibName:@"NCUserTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    [self.tableView setRowHeight:72.0];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self fetchData:self];
}

-(void)fetchData:(id)sender{
    @weakify(self);
    [NCLoadingView showInView:self.view];
    [[[userService getMembersByWorldId:self.worldModel.worldId] retry:3] subscribeNext:^(id x) {
        @strongify(self);
        users = [x mutableCopy];
        [NCLoadingView hideAllFromView:self.view];
        [self.tableView reloadData];
    }error:^(NSError *error) {
        [NCLoadingView hideAllFromView:self.view];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return users.count;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *myUserId = [NSUserDefaults standardUserDefaults].userModel.userId;
    NSString *myRole = [NSUserDefaults standardUserDefaults].userModel.role;
    UserModel *userModel = [users objectAtIndex:indexPath.row];
    if ([userModel.userId isEqualToString:myUserId]) {
        return NO;
    }
    if ([myRole isEqualToString:@"admin"]) {
        return YES;
    }
    if ([self.worldModel.moderatorUserIds containsObject:myUserId]) {
        return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UserModel *userModel = [users objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [users removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        @weakify(self);
        [[userService removeUserFromWorld:self.worldModel.worldId userId:userModel.userId] subscribeNext:^(id x) {
            @strongify(self);
            [CSNotificationView showInViewController:self tintColor:[UIColor greenColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Save your information successfully! Thank you" duration:2.0];
        } error:^(NSError *error) {
            @strongify(self);
            [CSNotificationView showInViewController:self tintColor:[UIColor redColor] font:[UIFont fontWithName:kTrocchiFontName size:16.0] textAlignment:NSTextAlignmentLeft image:nil message:@"Uh Oh! We couldn't delete this user :-(" duration:2.0];
        } completed:^{
            @strongify(self);
            [self fetchData:self];
        }];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.alpha = 0;
    UserModel *userModel = [users objectAtIndex:indexPath.row];
    [cell.spriteImageView sd_setImageWithURL:[NSURL URLWithString:userModel.spriteUrl]];
    cell.nameLabel.text = userModel.name;
    cell.aboutLabel.text = userModel.about;
    
    
    if ([self.worldModel.memberUserIds containsObject:userModel.userId]) {
        cell.roleLabel.text = @"Member";
    }
    
    if ([self.worldModel.moderatorUserIds containsObject:userModel.userId]) {
        cell.roleLabel.text = @"Moderator";
    }


    [UIView animateWithDuration:0.10 animations:^{
        cell.alpha = 1;
    }];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UserModel *userModel = [users objectAtIndex:indexPath.row];
    
    if ([userModel.userId isEqualToString:[NSUserDefaults standardUserDefaults].userModel.userId]) {
        return;
    }
    
    NCPrivateChatViewController *privateChatViewController = [[NCPrivateChatViewController alloc]init];
    privateChatViewController.regardingUserId = [userModel.userId copy];
    privateChatViewController.regardingUserName = [userModel.name copy];
    privateChatViewController.regardingUserSpriteUrl = [userModel.spriteUrl copy];
    
    [self.navigationController pushRetroViewController:privateChatViewController];
}

@end
