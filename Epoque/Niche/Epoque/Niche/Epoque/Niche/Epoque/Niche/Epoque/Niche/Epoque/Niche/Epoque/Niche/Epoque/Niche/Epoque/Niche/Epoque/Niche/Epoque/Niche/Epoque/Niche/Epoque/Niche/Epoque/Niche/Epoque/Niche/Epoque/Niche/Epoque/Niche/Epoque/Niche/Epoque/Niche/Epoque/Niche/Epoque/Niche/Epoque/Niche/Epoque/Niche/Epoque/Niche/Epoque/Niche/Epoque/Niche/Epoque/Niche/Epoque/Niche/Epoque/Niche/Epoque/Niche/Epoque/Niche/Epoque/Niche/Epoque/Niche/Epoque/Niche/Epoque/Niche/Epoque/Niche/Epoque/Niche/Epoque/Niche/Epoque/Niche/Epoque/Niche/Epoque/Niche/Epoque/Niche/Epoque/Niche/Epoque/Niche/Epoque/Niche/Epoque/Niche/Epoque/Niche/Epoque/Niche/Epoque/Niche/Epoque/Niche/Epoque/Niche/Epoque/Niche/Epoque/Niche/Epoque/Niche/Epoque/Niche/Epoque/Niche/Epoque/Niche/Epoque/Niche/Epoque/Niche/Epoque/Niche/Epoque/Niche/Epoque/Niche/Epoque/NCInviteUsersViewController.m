//
//  NCInviteUsersViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 4/7/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCInviteUsersViewController.h"

@interface NCInviteUsersViewController ()

@end

@implementation NCInviteUsersViewController{
    NSArray *users;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.worldName;
    users = [NSArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

@end
