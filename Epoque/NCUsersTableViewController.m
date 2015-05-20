//
//  NCUsersTableViewController.m
//  Epoque
//
//  Created by Maximilian Alexander on 5/17/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCUsersTableViewController.h"
#import "WorldModel.h"
#import "NCUserTableViewCell.h"
@interface NCUsersTableViewController ()

@end
NSString *CellIdentifier = @"UserCell";
@implementation NCUsersTableViewController{
    NSMutableArray *users;
    WorldModel *world;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"NCUserTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    self.tableView.rowHeight = 72.0;
    [self setUpBackButton];
    users = [NSMutableArray array];
    @weakify(self);
    [[[[self getWorldById:self.worldId] doNext:^(WorldModel *x) {
        @strongify(self);
        world = x;
        self.title = x.name;
    }] flattenMap:^RACStream *(WorldModel *worldModel) {
        @strongify(self);
        return [self getMembersByUserIds:world.memberUserIds];
    }] subscribeNext:^(NSArray *x) {
        @strongify(self);
        users = [x mutableCopy];
        [self.tableView reloadData];
    }];
    
}

-(RACSignal *)getWorldById:(NSString *)worldId{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"worlds"] childByAppendingPath:self.worldId] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            WorldModel *model = [[WorldModel alloc]initWithSnapshot:snapshot];
            [subscriber sendNext:model];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

-(RACSignal *)getMembersByUserIds:(NSArray *)userIds{
    return [[[userIds.rac_sequence.signal flattenMap:^RACStream *(id value) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [[[[[Firebase alloc]initWithUrl:kFirebaseRoot] childByAppendingPath:@"users"] childByAppendingPath:value] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if ([snapshot.value isKindOfClass:[NSNull class]]) {
                    [subscriber sendNext:nil];
                }else{
                    UserModel *userModel = [[UserModel alloc]initWithSnapshot:snapshot];
                    [subscriber sendNext:userModel];
                }
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }] filter:^BOOL(id value) {
        return [value isKindOfClass:[UserModel class]] && value != nil;
    }] collect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCUserTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UserModel *userModel = [users objectAtIndex:indexPath.row];
    [cell.spriteImageView sd_setImageWithURL:[NSURL URLWithString:userModel.spriteUrl]];
    cell.nameLabel.text = userModel.name;
    cell.aboutLabel.text = userModel.about;
    if ([world.moderatorUserIds containsObject:userModel.userId]) {
        cell.roleLabel.text = @"Moderator";
    }else{
        cell.roleLabel.text = @"";
    }
    return cell;
}


@end
