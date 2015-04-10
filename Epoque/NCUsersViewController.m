//
//  NCUsersViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 3/31/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCUsersViewController.h"
#import "NCUserService.h"
#import "NCWorldService.h"
#import "NCUserTableViewCell.h"
@interface NCUsersViewController ()

@end

@implementation NCUsersViewController{
    NSMutableArray *users;
    NCUserService *userService;
    NCWorldService *worldService;
}
static NSString *CellIdentifier = @"CellIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton];
    userService = [NCUserService sharedInstance];
    worldService = [NCWorldService sharedInstance];
    self.title = @"Users";
    users = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NCUserTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    [self.tableView setRowHeight:72.0];
    
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.alpha = 0;
    UserModel *userModel = [users objectAtIndex:indexPath.row];
    [cell.spriteImageView sd_setImageWithURL:[NSURL URLWithString:userModel.spriteUrl]];
    cell.nameLabel.text = userModel.name;
    cell.aboutLabel.text = userModel.about;

    [UIView animateWithDuration:0.10 animations:^{
        cell.alpha = 1;
    }];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
